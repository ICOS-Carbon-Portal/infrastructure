#!/usr/bin/python3
import os
from subprocess import check_output


BBCLIENT = '{{ bbclient_home }}' #/bin/bbclient'

def get_latest_backup_date(host, location):
    os.environ['BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK'] = "y"
    os.environ['BORG_RELOCATED_REPO_ACCESS_IS_OK'] = "y"

    # FIXME: bbclient has a hardcoded/templatized default for host/location,
    # so passing these is kind of strange.
    return check_output(f"{BBCLIENT} list --short --last 1 {host}:{location}",
                        shell=1, text=1).strip()


def restore_latest_backup(host, location, db, user, ignore_role_stmts, latest_backup_date):
    exec_container = f"docker exec -i {db} psql -U {user}"

    extracted_backup = check_output(f"{BBCLIENT} extract --stdout {host}:{location}::{latest_backup_date}", shell=1)

    if ignore_role_stmts:
        remove_role_stmts = check_output("egrep -v '^(CREATE|ALTER) ROLE'", shell=1,
                                         input=extracted_backup)

        return check_output(exec_container, input=remove_role_stmts, shell=1)
    else:
        return check_output(exec_container, input=extracted_backup, shell=1)


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

