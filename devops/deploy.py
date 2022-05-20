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
import click

def die(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


@click.command(context_settings={"ignore_unknown_options": True})
@click.option('-i', 'inventory', default='production')
@click.argument('playbook')
@click.argument("args", nargs=-1, required=False)
def main(inventory, playbook, args):
    inventory += ".inventory"
    if not os.path.exists(inventory):
        die("Cannot find %s in %s" % (inventory, os.getcwd()))

    # Special case - print facts for host.
    if len(args) == 1 and playbook == "facts":
        ARGS = ["ansible", args[0], '-m', 'setup', '-i', inventory]
    # Standard case - run playbook.
    else:
        playbook += ".yml"
        if not os.path.exists(playbook):
            die("Cannot find %s in %s" % (playbook, os.getcwd()))

        # The remaining arguments are either tags or options to ansible.
        TAGS = ["-t%s" % tag for tag in args if not tag.startswith('-')]
        OPTS = [opt for opt in args if opt.startswith('-')]
        ARGS = ['ansible-playbook', '-i', inventory, playbook] + TAGS + OPTS

    print(*ARGS)
    os.execvp(ARGS[0], ARGS)


if __name__ == '__main__':
    # Try to find out in which directory this script lives.
    home = os.path.dirname(os.path.realpath(sys.argv[0]))

    # Change to the directory where the playbooks lives. Ansible uses the
    # current working directory as a starting point when locating its files.
    os.chdir(home)

    main()
