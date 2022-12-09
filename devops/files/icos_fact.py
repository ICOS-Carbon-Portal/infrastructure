#!/usr/bin/python3

import json
import subprocess
from pathlib import Path

def stdout(*args):
    return subprocess.check_output(args, shell=True)

def ifsh(cmd):
    return subprocess.run(cmd, shell=1).returncode == 0

facts = {}
facts['inside_lxd'] = Path('/dev/lxd').exists()
facts['root_is_zfs'] = ifsh('[ $(findmnt -no FSTYPE /) = zfs ]')

print(json.dumps({'icos': facts}))
