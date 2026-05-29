-- Auto-generated from absent.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some [ "vars[item] is undefined" ],
      loop = Some [ "nginxsite_name" ]
    }
  , Task::{
      name = Some "Remove config file",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = Some "{{ item }}"
      , recurse = None Bool
      , src = None Text
    },
      loop = Some [
        "{{ nginxsite_path_enable }}"
      , "{{ nginxsite_path_available }}"
      , "{{ nginxsite_path_confd }}"
    ]
    }
  , Task::{
      name = Some "Reload nginx",
      systemd = Some {
        name = Some "nginx"
      , state = Some "reloaded"
      , daemon_reload = None Bool
      , enabled = None Text
      , `daemon-reload` = None Text
      , status = None Text
    },
      changed_when = Some "False"
    }
]
