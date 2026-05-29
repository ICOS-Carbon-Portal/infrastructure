-- Auto-generated from metrics_remove.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove /opt/vmagent/file_sd_configs/nginx-exporter-host.yaml",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "/opt/vmagent/file_sd_configs/nginx-exporter-host.yaml"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Stop nginx-prometheus-exporter",
      systemd = Some {
        name = Some "nginx-prometheus-exporter"
      , state = Some "stopped"
      , daemon_reload = None Bool
      , enabled = Some "False"
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
  , Task::{
      name = Some "Remove /etc/systemd/system/nginx-prometheus-exporter.service",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "/etc/systemd/system/nginx-prometheus-exporter.service"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Remove /usr/local/sbin/nginx-prometheus-exporter",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "/usr/local/sbin/nginx-prometheus-exporter"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Remove /opt/downloads/nginx-prometheus-exporter/",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "/opt/downloads/nginx-prometheus-exporter/"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
]
