-- Auto-generated from metrics.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ dest : Text, content : Text })
    , shell : Optional Text
    , changed_when : Optional Bool
    , uri : Optional ({ url : Text })
    , retries : Optional Natural
  }
    , default =
        { copy = None ({ dest : Text, content : Text })
    , shell = None Text
    , changed_when = None Bool
    , uri = None ({ url : Text })
    , retries = None Natural
  }
    }

in  [
    Task::{
      name = "Enable stub_status for nginx",
      copy = Some {
        dest = "/etc/nginx/conf.d/stub_status.conf"
      , content = ''
        server {
          listen localhost:80;
          server_name localhost;

          location /metrics {
              stub_status on;
          }
        }

      ''
    }
    }
  , Task::{
      name = "reload nginx config",
      shell = Some "nginx -t && systemctl reload nginx",
      changed_when = Some False
    }
  , Task::{
      name = "Check that nginx /metrics respond",
      uri = Some { url = "{{ nginx_metrics_url }}" },
      retries = Some 10
    }
]
