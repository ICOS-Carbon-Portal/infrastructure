-- Auto-generated from prometheus.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create nextcloud-exporter config file",
      copy = Some {
        src = None Text
      , dest = "{{ nextcloud_exporter_conf_host }}"
      , mode = Some "og-w"
      , content = Some ''
        # https://github.com/xperimental/nextcloud-exporter#configuration-file
        server: "https://{{ nextcloud_domain }}"
        username: "nextcloud-exporter"
        password: "{{ nextcloud_exporter_pass }}"

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
]
