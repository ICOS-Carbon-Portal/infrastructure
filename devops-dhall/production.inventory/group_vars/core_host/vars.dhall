-- Auto-generated from ../../../../devops/production.inventory/group_vars/core_host/vars.yml

{
    postgis_admin_pass = "{{ vault_postgis_admin_pass }}"
  , postgis_writer_pass = "{{ vault_postgis_writer_pass }}"
  , postgis_reader_pass = "{{ vault_postgis_reader_pass }}"
  , rdflog_db_pass = "{{ vault_rdflog_db_pass }}"
  , stiltweb_atmoaccess_user_password = "{{ vault_stiltweb_atmoaccess_user_password }}"
  , doi_admins = "{{ vault_doi_admins }}"
  , doi_to_addresses = "{{ vault_doi_to_addresses }}"
  , cpmeta_sentry_dsn = "{{ vault_cpmeta_sentry_dsn }}"
  , cpdata_sentry_backend_dsn = "{{ vault_cpdata_sentry_backend_dsn }}"
  , cpdata_sentry_portal_dsn = "{{ vault_cpdata_sentry_portal_dsn }}"
}
