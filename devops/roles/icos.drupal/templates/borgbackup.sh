#!/bin/bash

set -Eeuo pipefail
cd "{{ drupal_home }}"

LOGFILE=backup.log

for project in {{ drupal_websites | join(" ") }}; do

    if [ ! -d "$project" ]; then
        echo "$project directory not found. Skipping." >> "$LOGFILE"
        continue
    fi

    cd "$project/drupal/docker"

    docker-compose down >& /dev/null
    # If bbclient fails, it might be because one of its repos cannot be
    # reached. In that case we want to continue looping through the other
    # projects
    {{ bbclient_all }} create --verbose --stats "::$project-{now}" {{ drupal_home }}/$project/drupal >> "$LOGFILE" 2>&1 || :
    docker-compose up -d >& /dev/null

    cd "{{ drupal_home }}"
done

# prune backups
{{ bbclient_all }} prune --keep-daily=90 --keep-weekly=-1
