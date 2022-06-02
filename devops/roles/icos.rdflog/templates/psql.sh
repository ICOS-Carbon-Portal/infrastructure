#!/bin/bash

set -Eueo pipefail

cd "{{ rdflog_home }}"

if [ -t 0 ] && [ -t 1 ]; then T=""; else T="-T"; fi

docker-compose exec $T -u postgres db psql "$@"
