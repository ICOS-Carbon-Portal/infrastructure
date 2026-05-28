-- Auto-generated from metrics_remove.yml

let Entry =
    { Type =
        { name : Text
    , file : Optional ({ name : Text, state : Text })
    , systemd : Optional ({ name : Text, enabled : Bool, state : Text })
  }
    , default =
        { file = None ({ name : Text, state : Text })
    , systemd = None ({ name : Text, enabled : Bool, state : Text })
  }
    }

in  [
    Entry::{
      name = "Remove /opt/vmagent/file_sd_configs/nginx-exporter-host.yaml",
      file = Some {
        name = "/opt/vmagent/file_sd_configs/nginx-exporter-host.yaml"
      , state = "absent"
    }
    }
  , Entry::{
      name = "Stop nginx-prometheus-exporter",
      systemd = Some { name = "nginx-prometheus-exporter", enabled = False, state = "stopped" }
    }
  , Entry::{
      name = "Remove /etc/systemd/system/nginx-prometheus-exporter.service",
      file = Some {
        name = "/etc/systemd/system/nginx-prometheus-exporter.service"
      , state = "absent"
    }
    }
  , Entry::{
      name = "Remove /usr/local/sbin/nginx-prometheus-exporter",
      file = Some { name = "/usr/local/sbin/nginx-prometheus-exporter", state = "absent" }
    }
  , Entry::{
      name = "Remove /opt/downloads/nginx-prometheus-exporter/",
      file = Some { name = "/opt/downloads/nginx-prometheus-exporter/", state = "absent" }
    }
]
