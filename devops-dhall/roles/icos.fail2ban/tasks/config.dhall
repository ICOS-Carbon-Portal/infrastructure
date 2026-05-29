-- Auto-generated from config.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create fail2ban config files",
      copy = Some {
        src = None Text
      , dest = "{{ item.dest }}"
      , mode = None Text
      , content = Some "{{ item.content }}"
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      loop = Some [ "{{ fail2ban_config_files }}" ],
      loop_control = Some { loop_var = None Text, label = Some "{{ item.dest }}" },
      notify = Some [ "fail2ban reload" ]
    }
]
