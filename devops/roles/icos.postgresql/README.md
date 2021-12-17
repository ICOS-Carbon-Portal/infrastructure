# Overview

+ Installs PostgresQL and optionally PostGIS.
+ Installs the psycopg2 python library (required by ansible).
+ Ubuntu only.
+ Uses the PostgresQL package archives.

# Options

## superuser password

By default the `postgres` user (the database superuser) doesn't have a password
set and the only way to login in is through a unix socket. Setting
`postgresql_postgres_password` sets a password:

    - role: icos.postgresql
      postgresql_postgres_password: "{{ vault_postgres_password }}"
    

## listen addresses

To connect to postgresql from another host, set `postgresql_listen_addresses`,
note the double quoting. This will restart the postgres server to take effect,
so watch out in production This is mostly useful when running postgres in a VM
and wanting to connect from other VMs, it should not be used to expose postgres
to the internet.

    - role: icos.postgresql
      postgresql_listen_addresses: "'*'"


## install postgis

The official postgresql package repos packages PostGIS as well, set
`postgresql_postgis_enable` to install it.

    - role: icos.postgresql
      postgresql_postgis_enable: true


## ssh keys for postgres user

Extra ssh keys can be installed for the postgres user.

    - include_role: name=icos.postgresql
      tags: postgresql
      vars:
        postgresql_ssh_keys: "{{ vault_postgis_extra_keys }}"



## pg_stat_statements

The following will install the pg_stat_statements extension and _restart_ postgres. 

    - include_role: name=icos.postgresql
      vars:
        postgresql_pg_stat_enable: true

Remember that pg_stat_statments will also have to be enabled for each
individual database:

    - name: Add the pg_stat_statements extension
      community.postgresql.postgresql_ext:
        name: pg_stat_statements
        db: cplog
        schema: public
    

## Lock version of Postgresql.

The role will install the latest version of postgresql that has been tested by
us. To lock the role to a specific version, do like this:


    - include_role: name=icos.postgresql
      tags: postgresql
      vars:
        # Lock the version in case the role gets upgraded.
        postgresql_version: 12
