#!/usr/bin/python3
import click
import os
import subprocess
from subprocess import check_output
import os


def get_latest_backup_date(host, location):
    os.environ['BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK'] = "y"

    list_all_backups = f"borg list --short {host}:{location}".split()
    all_backups = check_output(list_all_backups)
    
    return check_output(["tail", "-1"], input=all_backups).strip().decode("utf-8")


def restheart_mongo_container():
    names = check_output(["docker", "ps", "--format", "{{ '{{' }}.Names{{ '}}' }}"]).decode("utf-8").splitlines()
    for name in ("restheart_mongodb_1", "restheart-mongodb-1"):
        if name in names:
            return name
    raise RuntimeError(f"Could not find RestHeart MongoDB container among: {names}")


def restore_backup(host, location, backup_date):
    extract_backup = f"borg extract --stdout {host}:{location}::{backup_date}".split()
    exec_container = ["docker", "exec", "-i", restheart_mongo_container(), "mongorestore", "--archive", "--drop"]

    extracted_backup = check_output(extract_backup)

    return check_output(exec_container, input=extracted_backup, stderr=subprocess.STDOUT) 


@click.command('restore', help=f'Restore latest RestHeart backup')
@click.option('--host', type=click.STRING)
@click.option('--location', type=click.STRING)
def restore_restheart_db(host, location):

    print("Running restore backup task for RestHeart")

    latest_backup_date = get_latest_backup_date(host, location)

    print("Found latest backup to be from: ", latest_backup_date)

    log_file = "restheart_restore_log.txt"

    restore_output = restore_backup(host, location, latest_backup_date)

    with open(log_file, 'w') as f:
        f.write(restore_output.decode("utf-8"))

    print(f"Backup restore done. Log can be found in {log_file}")


if __name__ == '__main__':
    restore_restheart_db()
