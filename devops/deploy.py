#!/usr/bin/env python3
# Frontend for ansible-playbook + ICOS playbooks.
#
# This scripts assumes that:
#  1. It lives in the same directory as the ICOS playbooks
#  2. Each application has its own playbook
#  3. All tags begins with APPLICATION_
#  4. The default inventory is production.
#
# Installation:
# $ ln -s deploy.py $HOME/bin/deploy
#
# Special case, show facts for host:
# $ deploy facts fsicos2
#
# Show tags for cpmeta:
# $ deploy cpmeta --list-tasks
#
# Show tasks for cpmeta:
# $ deploy cpmeta --list-tasks
#
# Run only the backup tasks in the cpmeta playbook.
# $ deploy cpmeta backup
#
# Deploy new version of cpmeta to production.
# $ deploy cpmeta app -ecpmeta_jar_file=cpmeta.jar


import sys
import os

INVENTORY = "production.inventory"

def die(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


# Try to find out in which directory this script lives.
DEVOPS = os.path.dirname(os.path.realpath(sys.argv.pop(0)))

# Change to the directory where the playbooks lives. Ansible uses the current
# working directory as a starting point when locating its files.
os.chdir(DEVOPS)

if len(sys.argv) < 1:
    die("usage: deploy name(.yml) {tags}")

if not os.path.exists(INVENTORY):
    die("Cannot find %s in %s" % (INVENTORY, DEVOPS))

NAME = sys.argv.pop(0)

# Special case - print facts for host.
if len(sys.argv) == 1 and NAME == "facts":
    ARGS = ["ansible", sys.argv[0], '-m', 'setup', '-i', INVENTORY]
# Standard case - run playbook.
else:
    PLAYBOOK = "%s.yml" % NAME
    if not os.path.exists(PLAYBOOK):
        die("Cannot find %s in %s" % (PLAYBOOK, DEVOPS))

    # The remaining arguments are either tags or options to ansible.
    TAGS = ["-t%s" % tag for tag in sys.argv if not tag.startswith('-')]
    OPTS = [opt for opt in sys.argv if opt.startswith('-')]
    ARGS = ['ansible-playbook', '-i', INVENTORY, PLAYBOOK] + TAGS + OPTS

print(*ARGS)
os.execvp(ARGS[0], ARGS)
