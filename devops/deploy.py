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


@click.group()
def cli():
    pass


@cli.command()
@click.argument("host")
@click.option('-i', 'inventory', default='production')
def facts(host, inventory):
    args = ["ansible", host, '-m', 'setup', f'-i{inventory}.inventory']
    print(*args)
    os.execvp(args[0], args)


@cli.command()
@click.argument("host")
@click.option('-i', 'inventory', default='production')
def inventory(host, inventory):
    args = ["ansible", host, '-m', 'debug', '-a',
            'var=hostvars[inventory_hostname]', f'-i{inventory}.inventory']
    print(*args)
    os.execvp(args[0], args)


@cli.command()
@click.argument('glob')
@click.option('-i', 'inventory', default='production')
@click.option('--diff', is_flag=True)
def vars(glob, inventory, diff):
    """Show variables matching a glob.
    """
    bash = '/usr/bin/bash'
    if not diff:
        cmd = f"ansible-inventory -i{inventory}.inventory --toml --list | awk '$1 ~ /{glob}/' | sort -u"
        print(cmd)
        os.execvp(bash, [bash, '-c', cmd])
    else:
        print(f"Showing the difference from staging to production for variables matching '{glob}'")
        cmds = f"ansible-inventory -istaging.inventory --toml --list | awk '$1 ~ /{glob}/' | sort -u"
        cmdp = f"ansible-inventory -iproduction.inventory --toml --list | awk '$1 ~ /{glob}/' | sort -u"
        os.execvp(bash, ['bash', '-c', f"diff <({cmds}) <({cmdp})"])


@cli.command(context_settings=dict(ignore_unknown_options=True,
                                   allow_interspersed_args=False,
                                   allow_extra_args=True))
@click.option('-i', 'inventory', default='production')
@click.argument('playbook')
@click.pass_context
def run(ctx, inventory, playbook):
    """Run a playbook.
    """
    inventory += ".inventory"
    if not os.path.exists(inventory):
        die("Cannot find %s in %s" % (inventory, os.getcwd()))

    playbook += ".yml"
    if not os.path.exists(playbook):
        die("Cannot find %s in %s" % (playbook, os.getcwd()))

    # The remaining arguments are either tags or options to ansible.
    TAGS = ["-t%s" % tag for tag in ctx.args if not tag.startswith('-')]
    OPTS = [opt for opt in ctx.args if opt.startswith('-')]
    args = ['ansible-playbook', '-i', inventory, playbook] + TAGS + OPTS

    print(*args)
    os.execvp(args[0], args)


if __name__ == '__main__':
    # Try to find out in which directory this script lives.
    home = os.path.dirname(os.path.realpath(sys.argv[0]))

    # Change to the directory where the playbooks lives. Ansible uses the
    # current working directory as a starting point when locating its files.
    os.chdir(home)

    cli()
