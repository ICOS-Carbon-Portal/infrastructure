#!/usr/bin/python3
import os
import subprocess
from subprocess import check_output


BBCLIENT = '{{ bbclient_home }}' #/bin/bbclient'

def get_latest_backup_date(host, location):
    os.environ['BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK'] = "y"
    os.environ['BORG_RELOCATED_REPO_ACCESS_IS_OK'] = "y"

    list_all_backups = f"{BBCLIENT} list --short {host}:{location}".split()
    all_backups = check_output(list_all_backups)
    
    return check_output(["tail",  "-1"], input=all_backups).strip().decode("utf-8")


def restore_latest_backup(host, location, db, user, ignore_role_stmts, latest_backup_date):
    extract = f"{BBCLIENT} extract --stdout {host}:{location}::{latest_backup_date}".split()
    exec_container = f"docker exec -i {db} psql -U {user}".split()

    extracted_backup = check_output(extract)

    if ignore_role_stmts:
        remove_role_stmts = check_output([
            'egrep',
            '-v',
            '^(CREATE|ALTER) ROLE'
        ], input=extracted_backup)

        return check_output(exec_container, input=remove_role_stmts)
    else:
        return check_output(exec_container, input=extracted_backup)


def restore_postgresql(host, location, db, user, ignore_role_stmts):

    print("Running restore task")

    latest_backup_date = get_latest_backup_date(host, location)

    print("Found latest backup to be from: ", latest_backup_date)
    
    log_file = f"{db}_restore_log.txt"

    restoration_output = restore_latest_backup(host, location, db, user, ignore_role_stmts, latest_backup_date)

    print("Extracted and transferred latest backup in docker container")

    with open(log_file, 'w') as f:
        f.write(restoration_output.decode("utf-8"))

    print(f"Backup restore done. Log can be found in {log_file}")

