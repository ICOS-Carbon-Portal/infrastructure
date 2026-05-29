-- Auto-generated from config_absent.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Fail if user is trying to remove main config file",
      fail = Some { msg = "Refusing to remove main config file." },
      when = Some [ "telegraf_config_file == \"telegraf.conf\"" ]
    }
  , Task::{
      name = Some "Remove telegraf config file",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "{{ telegraf_config_root }}/{{ telegraf_config_file }}"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    },
      notify = Some [ "reload telegraf" ]
    }
]
