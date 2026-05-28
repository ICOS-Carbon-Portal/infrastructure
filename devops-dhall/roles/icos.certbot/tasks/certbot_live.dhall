-- Auto-generated from certbot_live.yml

let Item =
    { Type =
        { block : Optional (List ({ import_tasks : Text }))
    , name : Optional Text
    , set_fact : Optional ({ certbot_nginx_conf : Text })
  }
    , default =
        { block = None (List ({ import_tasks : Text }))
    , name = None Text
    , set_fact = None ({ certbot_nginx_conf : Text })
  }
    }

in  [
    Item::{ block = Some [
        { import_tasks = "certbot_generate_live.yml" }
    ] }
  , Item::{
      name = Some "Set nginx config variable",
      set_fact = Some {
        certbot_nginx_conf = ''
        ssl_certificate {{ certbot_live_crt }};
        ssl_certificate_key {{ certbot_live_key }};

      ''
    }
    }
]
