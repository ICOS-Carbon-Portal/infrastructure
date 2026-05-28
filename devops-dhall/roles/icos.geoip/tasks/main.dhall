-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , tags : Text
    , import_role : Optional Text
    , vars : Optional ({ nginxsite_domains : List Text })
  }
    , default =
        { import_tasks = None Text
    , import_role = None Text
    , vars = None ({ nginxsite_domains : List Text })
  }
    }

in  [
    Item::{ import_tasks = Some "geoip_setup.yml", tags = "geoip_setup" }
  , Item::{ import_tasks = Some "geoip_app.yml", tags = "geoip_app" }
  , Item::{ tags = "geoip_certbot", import_role = Some "name=icos.certbot2" }
  , Item::{
      tags = "geoip_nginx",
      import_role = Some "name=icos.nginxsite",
      vars = Some { nginxsite_domains = [ "{{ geoip_domain }}" ] }
    }
]
