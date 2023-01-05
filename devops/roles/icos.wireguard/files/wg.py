#!/usr/bin/python3
# Extend the builtin wg(1).

import glob
import re
import subprocess
import sys
import os


REAL_WG = '/usr/bin/wg'
CONTROL = '/sys/kernel/debug/dynamic_debug/control'
DEBUG_1 = f"echo 'module wireguard +p' | sudo tee {CONTROL}"
DEBUG_0 = f"echo 'module wireguard -p' | sudo tee {CONTROL}"


def parse_hosts():
    hosts = {}
    for fname in glob.glob('/etc/wireguard/*.conf'):
        lines = [l.strip() for l in open(fname)]
        for n, line in enumerate(lines):
            if not line.startswith('PublicKey = '):
                continue
            key = line.split(None, 2)[-1]
            if n > 2 and lines[n-1] == '[Peer]' and lines[n-2].startswith('# '):
                hosts[key] = lines[n-2].split(None, 1)[-1]
    return hosts


if __name__ == '__main__':
    # Override the 'show' subcommand to also show hostnames.
    if len(sys.argv) == 1 or sys.argv[1] == 'show':
        hosts = parse_hosts()
        env = os.environ.copy()
        env['WG_COLOR_MODE'] = 'always'
        txt = subprocess.run([REAL_WG, "show"] + sys.argv[2:],
                             env=env, text=1, check=1, capture_output=1)
        for l in txt.stdout.splitlines():
            print(l)
            # Find the host key in amongst the color escape codes.
            m = re.search('peer[^:]+: \x1b.{4}(.{43}=)', l)
            if m:
                print('  name: %s' % hosts.get(m.group(1), 'n/a'))
    # Add a 'debug' subcommand.
    elif len(sys.argv) > 1 and sys.argv[1] == 'debug':
        if not os.path.exists(CONTROL):
            print(f"Sorry, but {CONTROL} doesn't exist.")
            sys.exit(1)
        subprocess.check_call(DEBUG_1, shell=1)
        try:
            subprocess.run(('dmesg', '-Tw'), check=0)
        finally:
            subprocess.check_call(DEBUG_0, shell=1)
            print('Exit.')
    # For all other cases we hand over directly to the real wg.
    else:
        os.execv(REAL_WG, sys.argv)
