#!/usr/bin/python3

import click
import contextlib
import os
import subprocess
import tempfile


BBCLIENT = '{{ bbclient_home }}/bin/bbclient'

@click.group()
@click.option('--bbclient',
              help="Location of the bbclient command",
              default=BBCLIENT)
def cli(bbclient):
    global BBCLIENT
    bbclient = BBCLIENT


# <2022-07-01 fri> The compressed restore file (stdout.gz) is about 110MB. Once
# restored into postgresql, it takes up about 3.7GB of disk. Restoring from
# borg takes 10 seconds, injecting it into postgres takes 70 minutes!
@cli.command()
@click.option('--destdir', type=click.Path(dir_okay=True, exists=True,
                                           file_okay=False, writable=True))
def restore(destdir):
    """Restore rdflog production backups.

    This can take 5-10 minutes.
    """
    hostname = subprocess.check_output(['hostname'], text=1).strip()
    print("Assert that we're running on staging")
    assert hostname == 'staging', hostname
    print("Dropping database cplog")
    subprocess.check_output(['sudo', '-iu', 'postgres', '--',
                             'dropdb', 'cplog', '--if-exists'])
    lines = subprocess.check_output([BBCLIENT, 'list'], text=1).splitlines()
    last = lines[-1].split()[0]
    if destdir is None:
        print("Restoring to temporary directory (which will be deleted afterwards)")
        ctx = tempfile.TemporaryDirectory('postgis-restore')
    else:
        print(f"Restoring to {destdir}")
        ctx = contextlib.nullcontext(destdir)
    with ctx as tmp:
        os.chdir(tmp)
        # We first retrieve the backup to disk. This way we hold the borgbackup
        # lock as shortly as possible.
        print(f'Retrieving backup "{last}" and storing as stdout.gz')
        subprocess.run(f"{BBCLIENT} extract --stdout ::{last} "
                       f"| gzip -c > stdout.gz",
                       shell=True, check=True)


@cli.command()
@click.argument('args', nargs=-1, required=False)
def bbclient(args):
    """Passthrough to the postgis bbclient script.
    """
    os.execvp(BBCLIENT, [BBCLIENT, *args])


@cli.command("bbclient-all", context_settings={"ignore_unknown_options": True})
@click.argument('args', nargs=-1, required=False)
def bbclient_all(args):
    """Passthrough to the postgis bbclient-all script.
    """
    os.execvp(BBCLIENT+"-all", [BBLCIENT+"-all", *args])


if __name__ == '__main__':
    cli()
