-- Auto-generated from cpdata.yml

[
    {
      hosts = "fsicos2"
    , roles = [
        {
          role = "icos.certbot2",
          tags = "cert",
          certbot_name = Some "{{ cpdata_cert_name }}",
          certbot_domains = Some "{{ cpdata_domains }}",
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          cpdata_netcdf_folder = None Text
        }
      , {
          role = "icos.nginxsite",
          tags = "nginx",
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = Some "cpdata",
          nginxsite_file = Some "roles/icos.cpdata/templates/cpdata.conf",
          cpdata_netcdf_folder = None Text
        }
      , {
          role = "icos.cpdata",
          tags = "cpdata",
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          cpdata_netcdf_folder = Some "/disk/data/common/netcdf/dataDemo"
        }
      , {
          role = "icos.dataold",
          tags = "dataold",
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          cpdata_netcdf_folder = None Text
        }
    ]
  }
]
