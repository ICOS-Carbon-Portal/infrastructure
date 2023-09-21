import os
from subprocess import check_call, check_output

import click


# UTILS
def borg_get_latest(borg):
    os.environ['BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK'] = "y"
    os.environ['BORG_RELOCATED_REPO_ACCESS_IS_OK'] = "y"
    return check_output(f"{borg} list --short --last 1", shell=1, text=1).strip()


# CLI

@click.group()
def cli():
    pass


@cli.command()
@click.option('--bb', help="Path to bbclient executable",
              type=click.Path(executable=True))
@click.option('--repo', help="The bbserver repo from which to retrieve backups")
@click.option("--norole", is_flag=True,
              help='Filter out ROLE statements during restore')
@click.option("--user", required=True, help="Postgres user")
@click.option("--container", required=False,
              help="Pipe sql commands from backup into this container")
@click.option("--stdout", is_flag=True, help="Dump to stdout. For testing.")
@click.option('--overwrite', 'overwrite', is_flag=True,
              help="Actually run commands which OVERWRITES database")
def restore(bb, repo, norole, user, container, stdout, overwrite):
    """Restore a postgresql database from a borg backup.

    \b
    Restoring a database is done in phases, each with it's own options:
      * choose borg backup source
      * massage the sql statements
      * destination of the restore
      * debugging or overwrite
    
    \b
    # Choosing borg backup source
    The database can be retrieved using the path to a bbclient. This uses the
    host and repo location hardcoded into the specific bbclient.
      restore --bb /home/cpmeta/.bbclient/bin/bbclient

    \b
    Next option is to specify --repo. This relies on the borg binary being in
    your $PATH and any ssh host alias being configured:
      restore --repo fsicos2:~bbserver/repos/rdflog.repo

    \b
    # Massage the sql statements
    The --norole option will remove any '(CREATE|ALTER) ROLE' statements

    \b
    # Destination of the restore
    --stdout\t\tsimply print sql statements to stdout
    --container NAME\tpipe sql to psql in the given container

    \b
    # Debugging or overwrite
    By default, this command simply prints the command to be executed
    If the --overwrite option is given, it executes the command (thus
    overwriting the target database)
    """
    if bool(bb) == bool(repo):
        raise click.UsageError("Use either --bb or --repo")
    
    if bool(stdout) == bool(container):
        raise click.UsageError("Use either --stdout or --container")

    if repo:
        borg = f"BORG_REPO={repo} borg"
    if bb:
        borg = bb

    archive = borg_get_latest(borg)

    # Build a command, start by extracting the database to stdout.
    cmd = f"{borg} extract --stdout ::{archive}"

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
