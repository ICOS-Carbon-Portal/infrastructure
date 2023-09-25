#!/usr/bin/env python3
# Frontend for ansible-playbook + ICOS playbooks.
import sys
import os
import click
import glob
from pathlib import Path


# Instruct click to pass unknown options and extra arguments unmolested. This
# way we can pass them on to ansible.
PASS_ARGS = dict(context_settings=dict(
    ignore_unknown_options=True,
    allow_interspersed_args=False,
    allow_extra_args=True,
))

# Most subcommands take the same inventory parameter, define it here.
OPTION_INVENTORY = click.option("-i", "--inventory",
                                default="production",
                                show_default=True,
                                help='select inventory')


# UTILS
def die(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


def find_playbook(expr):
    """Use a glob-like expression to find playbooks.

    Examples:
    "foo.yml" matches ./foo.yml
    "foo" also matches ./foo.yml
    "prom/vm" matches ./prometheus/vmagent.yml
    """
    # first try an exact match
    playbook = Path(f'{expr}.yml')
    if playbook.exists():
        return playbook

    # maybe the user wants a subdirectory
    if '/' in expr:
        dname, pname = expr.split('/', 1)
        matches = glob.glob(f'{dname}*/{pname}*.yml')
    else:
        matches = glob.glob(f'*{expr}*.yml')

    if len(matches) == 0:
        die(f'No playbooks match "{expr}"')
    elif len(matches) > 1:
        die(f'More than one playbook match "{expr}" - {",".join(matches)}')

    return Path(matches[0])


def find_devops_dir():
    """Find the devops directory, starting from __file__.
    """
    # __file__ == X/infrastructure/deploy/src/icos_deploy/cli.py
    here = Path(__file__)
    devops = here.parent.parent.parent.parent / 'devops'
    assert devops.is_dir()
    return devops


# CLI
@click.group()
def cli():
    # Change to the directory where the playbooks lives. Ansible uses the
    # current working directory as a starting point when locating its files.
    devops = find_devops_dir()
    print(f'cd {devops}')
    os.chdir(devops)


@cli.command(**PASS_ARGS)
@click.pass_context
@OPTION_INVENTORY
@click.argument("host")
def adhoc(ctx, inventory, host):
    """Run adhoc command, extra args passed to ansible(1).
    """
    cmd = ["ansible", f"-i{inventory}.inventory", host, *ctx.args]
    print(*cmd, *ctx.args)
    os.execvp(cmd[0], cmd + ctx.args)


@cli.command(**PASS_ARGS)
@click.pass_context
@OPTION_INVENTORY
@click.argument("host")
def facts(ctx, inventory, host):
    """Dump all gathered facts for host by running the setup module.
    """
    cmd = ["ansible", host,"-m", "setup", f"-i{inventory}.inventory"]
    print(*cmd, *ctx.args)
    os.execvp(cmd[0], cmd + ctx.args)


@cli.command()
@OPTION_INVENTORY
@click.argument("host")
def hostvars(inventory, host):
    """Shows all variables set for a host.

    This means all gathered facts + all inventory variables (including those
    from the vault).
    """
    args = ["ansible", host, "-m", "debug", "-a",
            "var=hostvars[inventory_hostname]",
            f"-i{inventory}.inventory"]
    print(*args)
    os.execvp(args[0], args)


@cli.command()
@OPTION_INVENTORY
@click.argument("glob")
@click.option("--diff", is_flag=True)
def vars(inventory, glob, diff):
    """Show variables matching a GLOB.

    When DIFF is true, show the diff between the production and staging
    inventories for the given GLOB.
    """
    template = (f"ansible-inventory -i{{}}.inventory --toml --list"
                f"| awk '$1 ~ /{glob}/' | sort -u")

    bash = "/usr/bin/bash"
    if not diff:
        cmd = template.format(inventory)
        print(cmd)
        os.execvp(bash, [bash, "-c", cmd])
    else:
        print(f"Showing difference from staging to production for '{glob}'")
        cmds = template.format('staging')
        cmdp = template.format('production')
        os.execvp(bash, ["bash", "-c", f"diff <({cmds}) <({cmdp})"])


@cli.command(**PASS_ARGS)
@click.pass_context
@OPTION_INVENTORY
@click.argument("playbook")
def run(ctx, inventory, playbook):
    """Run a playbook.

    Unknown options are passed along to ansible.

    \b
    Run the icosprod.yml playbook:
      icos run foo

    \b
    Run prometheus/vmagent.yml:
      icos run prom/vm

    \b
    Run prometheus/vmagent.yml but only the 'conf' tags
      icos run prom/vm conf

    \b
    Run prometheus/vmagent.yml, conf tags, with diffs
      icos run prom/vm conf -D
    """
    inventory += ".inventory"
    if not os.path.exists(inventory):
        die(f"Cannot find {inventory} in {os.getcwd()}")

    playbook = find_playbook(playbook)

    # The remaining arguments are either tags or options to ansible.
    tags = [f"-t{arg}" for arg in ctx.args if not arg.startswith("-")]
    opts = [arg for arg in ctx.args if arg.startswith("-")]
    args = ["ansible-playbook", "-i", inventory, playbook] + tags + opts

    print(*args)
    os.execvp(args[0], args)


@cli.command(**PASS_ARGS)
@click.pass_context
@OPTION_INVENTORY
@click.argument("playbook")
def lint(ctx, inventory, playbook):
    """Run ansible-lint.
    """
    playbook = find_playbook(playbook)
    args = ["ansible-lint", "--offline", "-p", "-i", inventory, playbook]
    print(*args)
    os.execvp(args[0], args)
