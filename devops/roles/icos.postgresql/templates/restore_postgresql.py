#!/usr/bin/python3
import os
from subprocess import check_output


BBCLIENT = '{{ bbclient_home }}' #/bin/bbclient'

def get_last_archive(host, location):
    os.environ['BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK'] = "y"
    os.environ['BORG_RELOCATED_REPO_ACCESS_IS_OK'] = "y"

    # FIXME: bbclient has a hardcoded/templatized default for host/location,
    # so passing these is kind of strange.
    return check_output(f"{BBCLIENT} list --short --last 1 {host}:{location}",
                        shell=1, text=1).strip()


def restore_latest_backup(host, location, db, user,
                          ignore_role_stmts, archive_name):
    cmd = f"{BBCLIENT} extract --stdout {host}:{location}::{archive_name}"

    # FIXME - surely there's an option to psql for this?
    if ignore_role_stmts:
        cmd += " | egrep -v '^(CREATE|ALTER) ROLE'"

    cmd += " | docker exec -i {db} psql -U {user}"
    return check_output(cmd, shell=1)



def restore_postgresql(host, location, db, user, ignore_role_stmts):

    print("Running restore task")

    last_archive = get_last_archive(host, location)

    print("Found last backup to be: ", last_archive)
    
    log_file = f"{db}_restore_log.txt"

    restoration_output = restore_latest_backup(host, location, db, user, ignore_role_stmts, last_archive)

    print("Extracted and transferred latest backup in docker container")

    with open(log_file, 'w') as f:
        f.write(restoration_output.decode("utf-8"))

    print(f"Backup restore done. Log can be found in {log_file}")

