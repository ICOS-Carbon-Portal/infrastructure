-- Auto-generated from main.yml

{
    cpmeta_user = "cpmeta"
  , cpmeta_home = "/home/cpmeta"
  , cpmeta_rdfstorage_path = "./rdfStorage"
  , cpmeta_servicename = "cpmeta"
  , cpmeta_readonly_mode = False
  , cpmeta_db_name = "rdflog"
  , cpmeta_db_user = "rdflog"
  , cpmeta_db_port = 2345
  , cpmeta_db_pass = "{{ rdflog_db_pass }}"
  , doi_password_icos = "{{ vault_doi_password }}"
  , cpmeta_backup_enable = True
  , cpmeta_bind_addr = "{{ coreapp_bind_addr }}"
  , cpmeta_host = "{{ coreapp_httpproxy_host }}"
  , cpmeta_port = 9094
}
