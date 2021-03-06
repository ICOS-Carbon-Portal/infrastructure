#!/bin/bash

set -Eeo pipefail

function dcomp { docker-compose -f docker-compose.yml "$@"; }
# https://github.com/docker/compose/issues/3352
function dexec { docker exec -i "$(dcomp ps -q db)" "$@"; }
function abort { >&2 echo "$@"; exit 1; }
function is_running { dcomp top | grep -q postgres; }

cd "{{ rdflog_home }}"

case "${1:-}" in
	"" | "help")
		echo "usage: ctl [cmd]"
		echo ""
		echo "where [cmd] is one of:"
		echo "  help    - this text"
		echo "  shell   - start a shell in the running container"
		echo "  status  - database/replication status"
		echo "  backup  - backup to file"
		echo "  restore - restore from file"
		;;
	"shell") dcomp exec db bash -i ;;
	"status")
		if ! is_running; then abort "rdflog is not running, try './ctl up'"
		else ./psql -q < .status.sql; fi
		;;
	"backup")
		[ "$#" -eq 2 ] || abort "please specify output file"
		[ ! -f "$2" ] || abort "refusing to overwrite existing output file '$2'"
		[ -f volumes/data/PG_VERSION ] || abort "no database present to backup"
		is_running || abort "rdflog needs to be started first ('./ctl up')";
		dexec pg_dump --schema public -v --format=c "{{ rdflog_db_name }}" > "$2"
		;;
	"restore")
		[ "$#" -eq 2 ] || abort "usage: rdflog restore input.sqlc"
		read -r -p "overwrite current database (y/n) ?" ans
		[ "$ans" == "y" ] || exit 0
		dexec pg_restore --verbose \
			  --clean --if-exists \
			  --no-owner --schema public \
			  --username="{{ rdflog_db_user }}" \
			  --dbname="{{ rdflog_db_name}}" < "$2"
		;;
	*)
		abort "unknown subcommand - try 'help'"
		;;
esac
