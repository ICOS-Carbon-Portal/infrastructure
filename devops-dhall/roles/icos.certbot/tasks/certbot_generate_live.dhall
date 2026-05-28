-- Auto-generated from certbot_generate_live.yml

let Task =
    { Type =
        { name : Text
    , stat : Optional ({ path : Text })
    , register : Optional Text
    , copy : Optional ({ dest : Text, content : Text })
    , when : Optional Text
    , service : Optional ({ name : Text, state : Text })
    , command : Optional Text
    , changed_when : Optional Text
    , set_fact : Optional ({ certbot_nginx_conf : Text })
  }
    , default =
        { stat = None ({ path : Text })
    , register = None Text
    , copy = None ({ dest : Text, content : Text })
    , when = None Text
    , service = None ({ name : Text, state : Text })
    , command = None Text
    , changed_when = None Text
    , set_fact = None ({ certbot_nginx_conf : Text })
  }
    }

in  [
    Task::{
      name = "Check if {{ certbot_conf_name }} exists",
      stat = Some { path = "{{ certbot_conf_path }}" },
      register = Some "_conf_file"
    }
  , Task::{
      name = "Create an initial nginx {{ certbot_conf_name }} for the certbot certification",
      register = Some "_write_conf",
      copy = Some {
        dest = "{{ certbot_conf_path }}"
      , content = ''
        server {
          listen 80;
          server_name {% for domain in certbot_domains %} {{ domain }}{% endfor %};

          location /.well-known {
              root /usr/share/nginx/html;
          }
        }

      ''
    },
      when = Some "not _conf_file.stat.exists"
    }
  , Task::{
      name = "Reload nginx",
      when = Some "_write_conf.changed",
      service = Some { name = "nginx", state = "reloaded" }
    }
  , Task::{
      name = "Install SSL certificate",
      register = Some "o",
      command = Some ''
      {{ certbot_bin }} certonly --authenticator nginx --non-interactive {% for domain in certbot_domains %} --domain {{ domain }} {% endfor %} --email {{ certbot_email }} --agree-tos --expand

    '',
      changed_when = Some "\"Certificate not yet due for renewal; no action taken.\" not in o.stdout"
    }
  , Task::{
      name = "Set nginx config variable",
      set_fact = Some {
        certbot_nginx_conf = ''
        ssl_certificate {{ certbot_live_crt }};
        ssl_certificate_key {{ certbot_live_key }};

      ''
    }
    }
]
