import os
from subprocess import check_output, check_call

import click


# UTILS
def bbclient_get_latest(bb):
    os.environ['BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK'] = "y"
    os.environ['BORG_RELOCATED_REPO_ACCESS_IS_OK'] = "y"
    return check_output(f"{bb} list --short --last 1", shell=1, text=1).strip()



# CLI

@click.group()
def cli():
    pass


@cli.command()
@click.option('--bb', required=True, help="Path to bbclient executable",
              type=click.Path(executable=True))
@click.option("--norole", is_flag=True,
              help='Filter out ROLE statements during restore')
@click.option("--user", required=True, help="Postgres user")
@click.option("--container", required=False,
              help="Pipe sql commands from backup into this container")
@click.option("--stdout", is_flag=True, help="Dump to stdout. For testing.")
@click.option('--overwrite', 'overwrite', is_flag=True,
              help="Actually run commands which OVERWRITES database")
def restore(bb, norole, user, container, stdout, overwrite):
    """Restore a postgresql backup from bbclient into a docker container.

    By default it just displays the command to run, use --overwrite to execute.
    """
    if stdout == bool(container):
        raise click.UsageError("Use use either --stdout or --container")

    archive = bbclient_get_latest(bb)

    # Build a command, start by extracting the database to stdout.
    cmd = f"{bb} extract --stdout ::{archive}"

    # If the user wants to strip ROLE ddl's, add a hack for that.
    if norole:
        # FIXME: This is fragile. There's most probably an option for psql
        # that does this better.
        cmd += " | egrep -v '^(CREATE|ALTER) ROLE'"

    if container:
        # Finally, pipe commands to a docker container.
        cmd += f" | docker exec -i {container} psql -U {user}"

    if overwrite:
        check_call(cmd, shell=1)
    else:
        print(f"Would have executed '{cmd}'")
