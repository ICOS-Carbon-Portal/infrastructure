#!/opt/edctl/venv/bin/python3 -u

import click
import docker
import os
import sys

from subprocess import run

REPO_URL = 'registry.icos-cp.eu/exploredata.%s.notebook'
PRODTEST = ['prod', 'test']

RRSYNC = '/usr/bin/rrsync'
TEMPLATES = {'test': '/docker/exploredata.test/jupyterhub_home/templates',
             'prod': '/docker/exploredata.prod/jupyterhub_home/templates'}


@click.group()
def cli():
    pass


@cli.command('images')
def cli_images():
    r = run(['docker', 'images', REPO_URL % '*'],
            text=1, check=1, capture_output=1)
    for n, line in enumerate(r.stdout.splitlines()):
        # Skip header.
        if n == 0:
            continue
        print(line)


@cli.command('pull')
@click.argument('what', type=click.Choice(PRODTEST))
def cli_pull(what):
    dock = docker.from_env()
    for update in dock.api.pull(REPO_URL % what, stream=True, decode=True):
        print(update.get('id'))
    print('done')
    img = dock.images.get(REPO_URL % what)
    # sha256:c166280023
    print('short_id %s' % img.short_id)


@cli.command('templates', context_settings={"ignore_unknown_options": True})
@click.argument('what', type=click.Choice(PRODTEST))
@click.argument('options', nargs=-1)
def cli_templates(what, options):
    # rrsync(1) works by extracting options from the environment.
    os.environ['SSH_ORIGINAL_COMMAND'] = ('rsync %s' % ' '.join(options))
    os.execvp(RRSYNC, [RRSYNC, '%s/' % TEMPLATES[what]])


if __name__ == '__main__':
    cmd = os.environ.get('SSH_ORIGINAL_COMMAND')
    if cmd is not None:
        argv = cmd.split()
    else:
        argv = sys.argv
    cli(args=argv[1:])
