#!/usr/bin/env python3
# Frontend for ansible-playbook + ICOS playbooks.
import sys
import os
import click
import glob


# Instruct click to pass unknown options and extra arguments unmolested. This
# way we pass them on to ansible.
PASS_ARGS = dict(context_settings=dict(
    ignore_unknown_options=True,
    allow_interspersed_args=False,
    allow_extra_args=True,
))


def die(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


def find_playbook(expr):
    # first try an exact match
    playbook = f'{expr}.yml'
    if os.path.exists(playbook):
        return playbook

    # maybe the user wants a subdirectory
    if '/' in expr:
        dname, pname = expr.split('/', 1)
        matches = glob.glob(f'{dname}*/{pname}*.yml')
    else:
        matches = glob.glob(f'{expr}*.yml')

    if len(matches) == 0:
        die(f'No playbooks match "{expr}"')
    elif len(matches) > 1:
        die(f'More than one playbook match "{expr}" - {",".join(matches)}')

    return matches[0]



@click.group()
def cli():
    pass


@cli.command(**PASS_ARGS)
@click.argument("host")
@click.option("-i", "inventory", default="production")
@click.pass_context
def facts(ctx, host, inventory):
    cmd = ["ansible", host,"-m", "setup", f"-i{inventory}.inventory"]
    print(*cmd, *ctx.args)
    os.execvp(cmd[0], cmd + ctx.args)


@cli.command()
@click.argument("host")
@click.option("-i", "inventory", default="production")
def hostvars(host, inventory):
    args = ["ansible", host, "-m", "debug", "-a",
            "var=hostvars[inventory_hostname]",
            f"-i{inventory}.inventory"]
    print(*args)
    os.execvp(args[0], args)


@cli.command()
@click.argument("glob")
@click.option("-i", "inventory", default="production")
@click.option("--diff", is_flag=True)
def vars(glob, inventory, diff):
    """Show variables matching a glob."""
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
@click.option("-i", "inventory", default="production")
@click.argument("playbook")
@click.pass_context
def run(ctx, inventory, playbook):
    """Run a playbook."""
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


if __name__ == "__main__":
    # Try to find out in which directory this script lives.
    home = os.path.dirname(os.path.realpath(sys.argv[0]))

    # Change to the directory where the playbooks lives. Ansible uses the
    # current working directory as a starting point when locating its files.
    os.chdir(home)

    cli()
