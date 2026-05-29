-- Auto-generated from ../devops/cpdata.yml

[
    {
      hosts = "fsicos2"
    , roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , certbot_name : Optional Text
        , certbot_domains : Optional Text
        , nginxsite_name : Optional Text
        , nginxsite_file : Optional Text
        , cpdata_netcdf_folder : Optional Text
      }
        , default =
            { certbot_name = None Text
        , certbot_domains = None Text
        , nginxsite_name = None Text
        , nginxsite_file = None Text
        , cpdata_netcdf_folder = None Text
      }
        }

    in  [
        Role::{
          role = "icos.certbot2",
          tags = "cert",
          certbot_name = Some "{{ cpdata_cert_name }}",
          certbot_domains = Some "{{ cpdata_domains }}"
        }
      , Role::{
          role = "icos.nginxsite",
          tags = "nginx",
          nginxsite_name = Some "cpdata",
          nginxsite_file = Some "roles/icos.cpdata/templates/cpdata.conf"
        }
      , Role::{
          role = "icos.cpdata",
          tags = "cpdata",
          cpdata_netcdf_folder = Some "/disk/data/common/netcdf/dataDemo"
        }
      , Role::{ role = "icos.dataold", tags = "dataold" }
    ]
  }
]
