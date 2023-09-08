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
    os.environ['BORG_RELOCATED_REPO_ACCESS_IS_OK'] = "y"

    list_all_backups = f"borg list --short {host}:{location}"
    all_backups = run_cmd(list_all_backups)
    
    return run_cmd("tail -1", all_backups.stdout).stdout.strip().decode("utf-8")


def restore_latest_backup(host, location, db, latest_backup_date):
    extract = f"borg extract --stdout {host}:{location}::{latest_backup_date}"
    db_user = "postgres" if db == "postgis" else db
    exec_container = f"docker exec -i {db} psql -U {db_user}"

    extracted_backup = run_cmd(extract)

    if db == "postgis":
        remove_role_stmts = subprocess.run([
            'egrep',
            '-v',
            '^(CREATE|ALTER) ROLE'
        ], input=extracted_backup.stdout, check=True, capture_output=True)

        return run_cmd(exec_container, remove_role_stmts.stdout)
    else:
        return run_cmd(exec_container, extracted_backup.stdout)


@click.command('restore', help=f'Restore latest postgresql backup')
@click.option('--host', type=click.STRING)
@click.option('--location', type=click.STRING)
@click.option('--db', type=click.STRING)
def restore(host, location, db):

    print("Running restore task")

    latest_backup_date = get_latest_backup_date(host, location)

    print("Found latest backup to be from: ", latest_backup_date)
    
    log_file = f"roles/icos.postgresql/{db}_restore_log.txt"

    restoration_output = restore_latest_backup(host, location, db, latest_backup_date)

    print("Extracted and transferred latest backup in docker container")

    with open(log_file, 'w') as f:
        f.write(restoration_output.stdout.decode("utf-8"))

    print(f"Backup restore done. Log can be found in {log_file}")


if __name__ == '__main__':
    restore()
