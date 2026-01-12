#!/opt/edctl/venv/bin/python3 -u

import click
import docker
import os
import sys

from subprocess import run

REPO_URL = "registry.icos-cp.eu/exploredata.%s.notebook"
PRODTEST = [
    'registry.icos-cp.eu/exploredata.prod.classic',
    'registry.icos-cp.eu/exploredata.prod.examples',
    'registry.icos-cp.eu/exploredata.prod.icos-notebooks',
    'registry.icos-cp.eu/exploredata.prod.icosbase',
    'registry.icos-cp.eu/exploredata.prod.ocean-carbon-course',
    'registry.icos-cp.eu/exploredata.prod.summer-school',
    'registry.icos-cp.eu/exploredata.test.classic',
    'registry.icos-cp.eu/exploredata.test.examples',
    'registry.icos-cp.eu/exploredata.test.icos-notebooks',
    'registry.icos-cp.eu/exploredata.test.icosbase',
    'registry.icos-cp.eu/exploredata.test.ocean-carbon-course',
    'registry.icos-cp.eu/exploredata.test.summer-school',
]

RRSYNC = "/usr/bin/rrsync"
TEMPLATES = {
    "test": "/docker/exploredata.test/jupyterhub_home/templates",
    "prod": "/docker/exploredata.prod/jupyterhub_home/templates",
}


def die(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)


@click.group()
def cli():
    pass


@cli.command("images")
def cli_images():
    r = run(["docker", "images", REPO_URL % "*"], text=1, check=1, capture_output=1)
    for n, line in enumerate(r.stdout.splitlines()):
        # Skip header.
        if n == 0:
            continue
        print(line)


@cli.command("pull")
@click.argument("what", type=click.Choice(PRODTEST))
def cli_pull(what):
    client = docker.from_env()
    tag = what
    for update in client.api.pull(tag, stream=True, decode=True):
        if error := update.get("error"):
            die(f"Error while pulling '{tag}' - {error}")
        print(update.get("id"))
    print("done")
    img = client.images.get(what)
    # sha256:c166280023
    print("short_id %s" % img.short_id)


@cli.command("templates", context_settings={"ignore_unknown_options": True})
@click.argument("what", type=click.Choice(PRODTEST))
@click.argument("options", nargs=-1)
def cli_templates(what, options):
    # rrsync(1) works by extracting options from the environment.
    os.environ["SSH_ORIGINAL_COMMAND"] = "rsync %s" % " ".join(options)
    os.execvp(RRSYNC, [RRSYNC, "%s/" % TEMPLATES[what]])


if __name__ == "__main__":
    cmd = os.environ.get("SSH_ORIGINAL_COMMAND")
    if cmd is not None:
        argv = cmd.split()
    else:
        argv = sys.argv
    cli(args=argv[1:])
