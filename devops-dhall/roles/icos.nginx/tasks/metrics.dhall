-- Auto-generated from metrics.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Enable stub_status for nginx",
      copy = Some {
        src = None Text
      , dest = "/etc/nginx/conf.d/stub_status.conf"
      , mode = None Text
      , content = Some ''
        server {
          listen localhost:80;
          server_name localhost;

          location /metrics {
              stub_status on;
          }
        }

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "reload nginx config",
      shell = Some "nginx -t && systemctl reload nginx",
      changed_when = Some "False"
    }
  , Task::{
      name = Some "Check that nginx /metrics respond",
      uri = Some {
        url = "{{ nginx_metrics_url }}"
      , return_content = None Bool
      , method = None Text
      , user = None Text
      , password = None Text
    },
      retries = Some 10
    }
]
