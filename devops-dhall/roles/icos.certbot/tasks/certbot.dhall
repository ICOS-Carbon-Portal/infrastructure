-- Auto-generated from certbot.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , when : Optional Text
    , name : Optional Text
    , set_fact : Optional Text
  }
    , default =
        { import_tasks = None Text
    , when = None Text
    , name = None Text
    , set_fact = None Text
  }
    }

in  [
    Item::{ import_tasks = Some "certbot_live.yml", when = Some "not certbot_fake_certificate" }
  , Item::{ import_tasks = Some "certbot_fake.yml", when = Some "certbot_fake_certificate" }
  , Item::{
      name = Some "Export certbot nginx config variable with prefix name",
      set_fact = Some "{{ certbot_conf_name }}_certbot_nginx_conf=\"{{certbot_nginx_conf}}\""
    }
]
