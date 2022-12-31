#!/bin/bash

set -xEeuo pipefail

for project in {{ drupal_websites | join(" ") }}; do
    cd "{{ drupal_home }}"

    if [ ! -d "$project" ]; then
        echo "$project directory not found. Skipping."
        continue
    fi

    cd "$project/drupal/docker"

    docker-compose down

    # If bbclient fails, it might be because one of its repos cannot be
    # reached. In that case we want to continue looping through the other
    # projects
    {{ bbclient_all }} create -xvs "::$project-{now}" {{ drupal_home }}/$project/drupal || :

    docker-compose up -d

    {{ bbclient_all }} prune -vs --keep-daily=90 --keep-weekly=-1 --prefix="$project-"
done
