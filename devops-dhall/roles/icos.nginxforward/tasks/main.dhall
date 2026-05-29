-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some [ "vars[item] is undefined" ],
      loop = Some [
        "nginxforward_port"
      , "nginxforward_name"
      , "nginxforward_cert"
      , "nginxforward_domains"
    ]
    }
  , Task::{
      import_tasks = Some "auth.yml",
      when = Some [ "nginxforward_users is defined" ],
      tags = Some [ "nginxforward_auth" ]
    }
  , Task::{
      name = Some "Copy config for {{ nginxforward_name }}",
      template = Some {
        src = "{{ nginxforward_file }}"
      , dest = "{{ nginxforward_path_available }}"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      notify = Some [ "reload nginx config" ]
    }
  , Task::{
      name = Some "Create symlink to sites-enabled",
      file = Some {
        path = None Text
      , state = Some "{% if nginxforward_enable %}link{% else %}absent{% endif %}"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = Some "{{ nginxforward_path_enabled }}"
      , recurse = None Bool
      , src = Some "{{ nginxforward_path_available }}"
    },
      when = Some [ "nginxforward_enable" ],
      notify = Some [ "reload nginx config" ]
    }
]
