-- Auto-generated from main.yml

{
    postgresql_postgis_enable = False
  , postgresql_pg_stat_enable = True
  , postgresql_postgres_password = None Text
  , postgresql_listen_addresses = None Text
  , postgresql_ssh_keys = None Text
  , postgresql_etc = "/etc/postgresql/{{ postgresql_version }}/main"
  , postgresql_confd = "{{ postgresql_etc }}/conf.d"
  , postgresql_pg_hba = "{{ postgresql_etc }}/pg_hba.conf"
  , postgresql_home = "/var/lib/postgresql"
  , postgresql_bin = "{{ postgresql_home }}/bin"
}
