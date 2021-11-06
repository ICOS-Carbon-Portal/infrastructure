#!/bin/bash

set -Eueo pipefail

cd "{{ restheart_home }}"

mkdir -p backup

docker-compose exec -T mongodb mongodump --quiet --archive > backup/server.archive

{{ bbclient_all }} create '::{now}' backup
{{ bbclient_all }} prune --keep-within 7d --keep-daily=30 --keep-weekly=150

rm -rf -- ./backup
