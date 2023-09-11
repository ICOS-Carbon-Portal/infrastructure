#!/usr/bin/python
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


def restore_latest_backup(host, location, latest_backup_date):
    extract_backup = f"borg extract --stdout {host}:{location}::{latest_backup_date}".split()
    exec_container = f"docker exec -i restheart_mongodb_1 mongorestore --archive --drop".split()

    extracted_backup = check_output(extract_backup)

    return check_output(exec_container, input=extracted_backup, stderr=subprocess.STDOUT) 


@click.command('restore', help=f'Restore latest RestHeart backup')
@click.option('--host', type=click.STRING)
@click.option('--location', type=click.STRING)
def restore(host, location):

    print("Running restore backup task for RestHeart")

    latest_backup_date = get_latest_backup_date(host, location)

    print("Found latest backup to be from: ", latest_backup_date)

    log_file = "/var/log/restheart_restore_log.txt" # variable instead?

    restore_output = restore_latest_backup(host, location, latest_backup_date)

    with open(log_file, 'w') as f:
        f.write(restore_output.decode("utf-8"))

    print(f"Backup restore done. Log can be found in {log_file}")


if __name__ == '__main__':
    restore()
