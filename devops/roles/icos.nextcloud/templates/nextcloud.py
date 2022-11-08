#!/usr/bin/python{{ python3_version }}
# Perform various sysadmin task for nextcloud.
# Used on the host which is running nextcloud in a docker container.

import click
import datetime
import os
import subprocess
import types
import yaml


NC_DOCKER_HOME = "{{ nextcloud_home }}"
NC_OCC_CMD = "./occ"


def occ_user_list_info():
    o = subprocess.check_output([NC_OCC_CMD, 'user:list', '--info'])
    # lst looks like:
    #   [{'user_id': [{attr1: val}, {attr2: val}]}]
    # Among the attributes, the user_id is listed once again.
    # Transform it into a list of merged-attribute-dicts-as-object.
    lst = yaml.safe_load(o)
    users = [types.SimpleNamespace(**{k:v
                              for user in lst
                              for _, dict_list in user.items()
                              for single_attr_dict in dict_list
                              for k, v in single_attr_dict.items()})]
    return users


# CLI
@click.group()
def cli():
    os.chdir(NC_DOCKER_HOME)


@cli.command('active', help='List active (seen last 3 hours) users')
@click.option('--hours', type=click.IntRange(1, 96), default=3)
def cli_active(hours):
    users = occ_user_list_info()
    delta = datetime.timedelta(hours=hours)
    now = datetime.datetime.now(tz=datetime.timezone.utc)
    for user in users:
        time_since_seen = now - user.last_seen
        if time_since_seen < delta:
            print(user.user_id, 'was last seen on', user.last_seen)


@cli.command('psql', help='Run psql in the db container')
def cli_psql():
    cmd = "docker-compose exec db psql --user nextcloud"
    print("Executing: ", cmd)
    subprocess.check_call(cmd.split())


@cli.command('shell', help='Start a bash shell in the app container')
def cli_shell():
    cmd = "docker-compose exec app bash"
    print("Executing: ", cmd)
    subprocess.check_call(cmd.split())


if __name__ == '__main__':
    cli()
