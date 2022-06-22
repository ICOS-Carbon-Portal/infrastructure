#!/bin/bash

cat > "$PGDATA"/pg_hba.conf <<EOF
# "local" is for Unix domain socket connections only
local   all             all                                     trust
# "all" doesn't match replication so we need a specific option for that
hostssl replication     all             all                     md5
host    all             all             all                     md5
EOF

# These two files are world readable so that this script can access them.
cp /docker-entrypoint-initdb.d/server.{key,crt} "$PGDATA"

# However, postgres will refuse to use them if they're "too readable".
chown postgres: $PGDATA/server.{key,crt}
chmod 0600 $PGDATA/server.{key,crt}
