#!/usr/bin/python{{ python3_version }}
import click
import os
import subprocess


def run_cmd(cmd, input = None):
    if input:
        return subprocess.run(cmd.split(), input=input, check=True, capture_output=True)
    else:
        return subprocess.run(cmd.split(), check=True, capture_output=True)


def get_latest_backup_date(host, location):
    os.environ['BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK'] = "y"

    list_all_backups = f"borg list --short {host}:{location}"
    all_backups = run_cmd(list_all_backups)
    
    return run_cmd("tail -1", all_backups.stdout).stdout.strip().decode("utf-8")


def restore_latest_backup(host, location, latest_backup_date):
    extract_backup = f"borg extract --stdout {host}:{location}::{latest_backup_date}"
    exec_container = f"docker exec -i restheart_mongodb_1 mongorestore --archive --drop"

    extracted_backup = run_cmd(extract_backup)

    return subprocess.run(exec_container.split(), input=extracted_backup.stdout, check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT) 


@click.command('restore', help=f'Restore latest RestHeart backup')
@click.option('--host', type=click.STRING)
@click.option('--location', type=click.STRING)
def restore(host, location):

    print("Running restore backup task for RestHeart")

    latest_backup_date = get_latest_backup_date(host, location)

    print("Found latest backup to be from: ", latest_backup_date)

    log_file = "roles/icos.restheart/restheart_restore_log.txt"

    restore_output = restore_latest_backup(host, location, latest_backup_date)

    with open(log_file, 'w') as f:
        f.write(restore_output.stdout.decode("utf-8"))

    print(f"Backup restore done. Log can be found in {log_file}")


if __name__ == '__main__':
    restore()
