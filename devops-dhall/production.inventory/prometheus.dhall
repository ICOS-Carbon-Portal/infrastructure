-- Auto-generated from ../../devops/production.inventory/prometheus.yml

{
    vmagent_hosts = {
      vars = {
        vmagent_pathprefix = "/vmagent"
      , vmagent_remote = "https://prom.icos-cp.eu/api/v1/write"
      , vmagent_auth = "{{ vault_vmagent_auth }}"
      , smartmon_enable = True
      , dirsize_enable = True
    }
    , hosts = {
        cdb = None Text
      , icos1 = { dockermon_enable = True, lxdmon_enable = True }
      , fsicos2 = {
          dockermon_enable = True
        , dirsize_initial = [ "/disk/data/nextcloud", "/var/log" ]
      }
      , fsicos3 = { lxdmon_enable = True }
    }
  }
}
