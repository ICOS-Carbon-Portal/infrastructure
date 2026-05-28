-- Auto-generated from core.yml

{
    all = {
      vars = {
        cpmeta_cities_domain = "citymeta.icos-cp.eu"
      , cpauth_cities_domain = "cityauth.icos-cp.eu"
      , cpdata_cities_domain = "citydata.icos-cp.eu"
      , cities_lxd_ip = "10.189.225.41"
      , rdflog_postgres_version = 15
      , cpmeta_domains = [ "{{ cpmeta_cities_domain }}" ]
      , cpdata_domains = [ "{{ cpdata_cities_domain }}" ]
      , postgis_dbs = [ "{{ postgis_cities_db_name }}" ]
      , restheart_dbs = [ "{{ restheart_cities_db_name }}" ]
      , cpmeta_bbclient_name = "citymeta"
      , restheart_bbclient_name = "cityrestheart"
      , postgis_bbclient_name = "citypostgis"
      , rdflog_bbclient_name = "cityrdflog"
      , cities_datafast_path = "/data_fast"
      , cpmeta_rdfstorage_path = "{{ cities_datafast_path }}/rdfStorage"
      , showUnderConstruction = "false"
      , showCarbonBadge = "true"
    }
    , children = {
        core_host = {
          hosts = { cities = None Text }
        , vars = {
            coreapp_bind_addr = "0.0.0.0"
          , restheart_bind_host = "0.0.0.0"
          , restheart_backup_enable = True
          , rdflog_backup_enable = True
          , rdflog_postgres_version = 15
          , cpmeta_filestorage_target = "{{ cpmeta_home }}/filestorage"
          , cpmeta_backup_enable = True
          , cpmeta_config_files = [
              "application_production.conf"
            , "application_cities_amendment.conf"
            , "application_cities_sensitive.conf"
          ]
          , cpdata_filestorage_target = "/data/dataAppStorage/"
          , cpdata_b2safe_dry_run = False
          , cpdata_config_files = [ "application_production.conf" ]
          , postgis_db_port = 5438
          , postgis_hostname = "127.0.0.1"
          , postgis_backup_enable = True
          , data_envries = [
              {
                name = "ICOSCities"
              , restheart_url = "http://127.0.0.1:{{ restheart_bind_port }}/{{ restheart_cities_db_name }}"
              , postgis_db_name = "{{ postgis_cities_db_name }}"
            }
          ]
        }
      }
      , core_server = {
          hosts = { fsicos2 = None Text }
        , vars = {
            coreapp_httpproxy_host = "cities.lxd"
          , coreapp_host_ip = "{{ cities_lxd_ip }}"
          , cpmeta_nginxsite_name = "cpmeta-cities"
          , cpmeta_certbot_name = "cpmeta-cities"
          , cpdata_certbot_name = "cpdata-cities"
          , cpdata_nginxsite_name = "cpdata-cities"
          , restheart_host = "cities.lxd"
          , restheart_nginxsite_name = "restheart-cities"
          , restheart_certbot_name = "restheart-cities"
          , restheart_basic_auth = "{{ city_restheart_basic_auth }}"
          , restheart_domains = [ "{{ restheart_cities_domain }}" ]
        }
      }
    }
  }
}
