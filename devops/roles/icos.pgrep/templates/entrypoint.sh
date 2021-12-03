#!/bin/bash

set -Eeo pipefail

if [ "$(id -u)" = '0' ]; then
    chown -R postgres:postgres "$PGDATA/.."
    chmod 700 "$PGDATA"
    chmod 600 "$PGDATA/../.pgpass"
    exec gosu postgres "$BASH_SOURCE" "$@"
fi

# Check whether database has been initialized.
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Connecting to peer and making sure that our replication slot exists"
    psql -d "$CONNINFO" -c "select * from                                              \
                            pg_create_physical_replication_slot('$SLOTNAME')           \
                                                    where not exists (                 \
                                                    select 1 from pg_replication_slots \
                                                    where slot_name = '$SLOTNAME')"
    echo "Starting basebackup"
    pg_basebackup -D "$PGDATA" -R -v -S "$SLOTNAME" -d "$CONNINFO" -w
    echo "Basebackup finished"
fi

echo "Starting postgres server"
postgres

