-- Auto-generated from certbot_fake.yml

let Item =
    { Type =
        { include_vars : Optional Text
    , name : Optional Text
    , command : Optional Text
    , args : Optional ({ creates : Text })
    , set_fact : Optional ({ certbot_nginx_conf : Text })
  }
    , default =
        { include_vars = None Text
    , name = None Text
    , command = None Text
    , args = None ({ creates : Text })
    , set_fact = None ({ certbot_nginx_conf : Text })
  }
    }

in  [
    Item::{ include_vars = Some "vars/{{ ansible_distribution | lower }}.yml" }
  , Item::{
      name = Some "Create self-signed certificate",
      command = Some ''
      openssl req -x509 -nodes -subj '/CN={{ certbot_fake_cn }}' -days 365 -newkey rsa:4096 -sha256 -keyout {{ certbot_fake_key }} -out {{ certbot_fake_crt }}

    '',
      args = Some { creates = "{{ certbot_fake_crt }}" }
    }
  , Item::{
      name = Some "Create nginx config string",
      set_fact = Some {
        certbot_nginx_conf = ''
        ssl_certificate {{ certbot_fake_crt }};
        ssl_certificate_key {{ certbot_fake_key}};

      ''
    }
    }
]
