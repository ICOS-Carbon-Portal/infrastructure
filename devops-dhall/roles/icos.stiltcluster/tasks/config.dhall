-- Auto-generated from config.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create stiltcluster configuration file",
      template = Some {
        src = "local.conf"
      , dest = "{{ stiltcluster_home }}"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      notify = Some [ "restart stiltcluster" ]
    }
]
