#!/usr/bin/python3
# Keep iptables ssh port-forwarding rules in sync with dnsmasq leases for VMs.
#
# Background:
#   The host only has a single public ip.
#   The host is running proxmox with lots of virtual machines.
#   Each virtual machine is to be accessible from the outside using ssh.
#
# Solution:
#   Use port-forwarding
#
# Example:
#   "ssh -p 60601 public_ip" connects to VM number 1 port 22.
#
# How does it work:
#   This script run as a systemd service. The service is woken up either by
#   dnsmasq (when the leases change) or by a systemd timer.
#
#   It parses dnsmasq leases to find the ip of the running virtual
#   machines. It uses qm(1) to find a mapping from external port number to
#   virtual machine (currently the mapping is stored as port of the virtual
#   machine's description (!). It then adds and deletes iptables(1) rules as
#   necessary.

# ruff: noqa: E701

import ipaddress
import json
import re
import shlex
import subprocess
import sys
from collections import namedtuple
from datetime import datetime, timedelta
from functools import cache
from pathlib import Path
from subprocess import check_call, check_output
from types import SimpleNamespace

import click

# GLOBALS
CMD_IPTABLES = "/usr/sbin/iptables"
CMD_IPTABLES_SAVE = "/usr/sbin/iptables-save"
ICOS_CHAIN = "ICOS-DNAT"

DNAT = namedtuple("DNAT", ["hport", "comment", "ip", "dport", "line"])
QM = namedtuple("QM", ["id", "name", "port"])


# UTILS
def run(cmd, **kwargs):
    default = {"check": True, "text": True}
    if isinstance(cmd, str):
        default["shell"] = True
    default.update(kwargs)
    print(f">>> {cmd=} <<<")

    if getattr(run, "dry_run", False):
        return None
    else:
        return subprocess.run(cmd, **default)  # noqa: PLW1510, S603


def die(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


def ip_json(arg):
    s = check_output(["/usr/sbin/ip", "-json", "-details",  # noqa: S603
                      *shlex.split(arg)])
    j = json.loads(s)
    return j


def auto_bridge():
    """Return the name of the first and only bridge."""
    match ip_json("link show type bridge"):
        # Surprisingly, if no bridges are present, this is the output.
        case [{},{},{},{},{}]: die("No bridges detected")
        # A single bridge
        case [{"ifname": ifname}]: return ifname
        case [_, _, *_] as bs: die(f"More than one bridge - {bs}")
        case bs: die(f"Could not parse bridges {bs}.")


def auto_interface():
    """Return the name of the first and only interface with a public ip."""
    result = []
    for d in ip_json("address show"):
        match d:
            case {"ifname": ifname, "addr_info": ai_list}:
                for ai in ai_list:
                    if ai.get("family") != "inet":
                        continue
                    ip = ipaddress.ip_address(ai.get("local", "0.0.0.0"))
                    if ip.is_global:
                        result.append(ifname)
    match len(result):
        case 0: die("Could not automatically find any interfaces.")
        case 1: return result[0]
        case _: die(f"Too many automatic interfaces {result}")




# CMD_IPTABLES
def parse_iptables():
    """Parse iptables-save(1) into (table, {chain: [rules] ...})"""
    table = None
    rules = {}
    # iptables-save will dump rules in a easy-to-parse format.
    output = check_output([CMD_IPTABLES_SAVE], text=1)  # noqa: S603

    for line in output.splitlines():
        if line.startswith("#"):
            continue
        elif line == "COMMIT":
            yield table, rules
            table = None
            rules = {}
        elif line.startswith("*"):
            table = line[1:]
        elif line.startswith(":"):
            continue
        elif line.startswith("-A"):
            [_, name, rest] = line.split(None, 2)
            rules.setdefault(name, []).append(rest)
        else:
            raise ValueError(line)


def parse_dnat_rule(rule):
    """Parse an iptables-save(1) line into a DNAT object."""
    # iptables-save seems to always output the options in the same order.
    if m := re.search(
        r"-p tcp"
        r'.*--dport (\d+).*--comment "([^"]+)"'
        r".*-j DNAT"
        r".*--to-destination ([^:]+):(\d+)",
        rule,
    ):
        # We're turning the dport into hport; it's the entire "host port" line
        # except the initial '-A ICOS-DNAT'
        return DNAT(*m.groups(), rule)
    raise ValueError(rule)


def parse_icos_dnat():
    """Return a DNAT object for each rule in the ICOS-DNAT chain."""
    tables = dict(parse_iptables())
    nat = tables["nat"]
    try:
        icos = nat[ICOS_CHAIN]
    except KeyError:
        check_call([CMD_IPTABLES, "-t", "nat", "-N", ICOS_CHAIN])  # noqa: S603
        check_call([CMD_IPTABLES,  # noqa: S603 fmt: skip
                    "-t", "nat",
                    "-I", "PREROUTING", "1",
                    "-j", ICOS_CHAIN])  # fmt: skip
        icos = []
    for rule in icos:
        yield parse_dnat_rule(rule)


def iptables_add_dnat(interface, ip, port, name):
    run([CMD_IPTABLES,
         "-t", "nat", "-A", ICOS_CHAIN, "-i", interface,
         "-p", "tcp", "--dport", port,
         "-j", "DNAT", "--to", f"{ip}:22",
         "-m", "comment", "--comment", f"(auto) ssh to {name}"])  # fmt: skip


def iptables_del_dnat(dnat):
    # dnat.line is the entire line output by iptables-save(1), which is the
    # same format we'll need to delete a line.
    run([CMD_IPTABLES, "-t", "nat", "-D", ICOS_CHAIN, *shlex.split(dnat.line)])


# DNSMASQ
def file_is_stale(path, age=timedelta(hours=6)):
    s = Path(path).stat()
    mtime = datetime.fromtimestamp(s.st_mtime)  # noqa: DTZ006
    cutoff = datetime.now() - age  # noqa: DTZ005
    if mtime < cutoff:
        return mtime
    return None


def parse_dnsmasq_leases(path):
    # We don't want to take any actions if dnsmasq for some reason isn't
    # running or if we're looking at the wrong lease file.
    if m := file_is_stale(path):
        raise RuntimeError(f"{path} is too old, mtime = {m}")
    for line in open(path):
        line = line.strip()  # noqa: PLW2901
        _, _, ip, name, _ = line.split()
        yield (ip, name)


# QM
@cache
def _qm_list():
    output = check_output(["/usr/sbin/qm", "list"], text=1)  # noqa: S603
    for n, line in enumerate(output.splitlines()):
        # skip header
        if n == 0:
            continue
        vmid, vmname, *rest = line.split()
        yield (vmid, vmname)


@cache
def qm_name_to_vmid(name):
    for vmid, vmname in _qm_list():
        if name == vmname:
            return vmid
    return None


@cache
def qm_vmid_to_port(vmid):
    config = qm_vmid_to_config(vmid)
    if m := re.search(r"port (\d+)", config.get("description", "")):
        return m.group(1)


@cache
def qm_vmid_to_config(vmid):
    output = check_output(["/usr/sbin/qm", "config", vmid], text=1)  # noqa: S603
    return dict(
        (s.strip() for s in line.split(":", 1)) for line in output.splitlines()
    )


@cache
def qm_name_to_port(name):
    vmid = qm_name_to_vmid(name)
    if vmid is not None:
        return qm_vmid_to_port(vmid)


@cache
def qm_list():
    for vmid, vmname in _qm_list():
        config = qm_vmid_to_config(vmid)
        # skip templates when listing VMs
        if bool(config.get("template", "0")):
            continue
        port = qm_vmid_to_port(vmid)
        yield QM(vmid, vmname, port)


# CLI
@click.group()
@click.option("--dry-run", is_flag=True)
@click.option("-i", "--interface", default="auto")
@click.option("-b", "--bridge", default="auto")
@click.pass_context
def cli(ctx, dry_run, interface, bridge):
    run.dry_run = dry_run

    if bridge == "auto":
        bridge = auto_bridge()
        if bridge is None:
            ctx.fail("Cannot find default bridge.")

    if interface == "auto":
        interface = auto_interface()
        if interface is None:
            ctx.fail("Cannot find default interface.")

    lease_file = Path(f"/var/lib/misc/dnsmasq.{bridge}.leases")
    if not lease_file.exists():
        raise click.UsageError(f"{lease_file} doesn't exist")

    ctx.obj = SimpleNamespace(lease_file=lease_file,
                              intferface=interface,
                              bridge=bridge)




@cli.command("run")
@click.pass_context
def cli_run(ctx):
    """Parse leases, adjust firewall rules. Used by the systemd service."""
    leases = list(parse_dnsmasq_leases(ctx.obj.lease_file))

    ip2name = {ip: name for ip, name in leases}  # noqa: C416
    name2ip = {name: ip for ip, name in leases}
    ip2port = {}

    print("parsing firewall rules, looking at vms")
    for r in parse_icos_dnat():
        name = ip2name.get(r.ip)
        if not name:
            print(f"  found rule for {r.ip} but no lease, removing rule.")
            iptables_del_dnat(r)
            continue
        ip2port[r.ip] = r.hport
        qmport = qm_name_to_port(name)
        if not qmport:
            print(f"  {name}: no port configured but a rule for {r.hport}")
        elif qmport == r.hport:
            print(f"  {name}: port {r.hport} ok")
        else:
            print(f"  {name}: port {r.hport} but configured to {qmport}")

    print("parsing vms, looking at firewall rules")
    for qm in qm_list():
        if qm.port is None:
            print(f" {qm.name}: no port configured")
        else:
            ip = name2ip.get(qm.name)
            if ip is None:
                print(f"  {qm.name}: has no assigned ip!")
                continue
            port = ip2port.get(ip)
            if port is None:
                print(f"  {qm.name}: no port rule, adding rule for {qm.port}")
                iptables_add_dnat(ctx.obj.interface, ip, qm.port, qm.name)
    print("done")


@cli.command("test", hidden=True)
@click.pass_context
def cli_test(_ctx):
    print(auto_bridge())
    print(auto_interface())
