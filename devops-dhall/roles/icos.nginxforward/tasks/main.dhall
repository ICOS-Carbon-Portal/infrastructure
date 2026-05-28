-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , fail : Optional ({ msg : Text })
    , when : Optional Text
    , loop : Optional (List Text)
    , import_tasks : Optional Text
    , tags : Optional Text
    , template : Optional ({ src : Text, dest : Text })
    , notify : Optional Text
    , file : Optional ({ dest : Text, src : Text, state : Text })
  }
    , default =
        { name = None Text
    , fail = None ({ msg : Text })
    , when = None Text
    , loop = None (List Text)
    , import_tasks = None Text
    , tags = None Text
    , template = None ({ src : Text, dest : Text })
    , notify = None Text
    , file = None ({ dest : Text, src : Text, state : Text })
  }
    }

in  [
    Item::{
      name = Some "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some "vars[item] is undefined",
      loop = Some [
        "nginxforward_port"
      , "nginxforward_name"
      , "nginxforward_cert"
      , "nginxforward_domains"
    ]
    }
  , Item::{
      when = Some "nginxforward_users is defined",
      import_tasks = Some "auth.yml",
      tags = Some "nginxforward_auth"
    }
  , Item::{
      name = Some "Copy config for {{ nginxforward_name }}",
      template = Some { src = "{{ nginxforward_file }}", dest = "{{ nginxforward_path_available }}" },
      notify = Some "reload nginx config"
    }
  , Item::{
      name = Some "Create symlink to sites-enabled",
      when = Some "nginxforward_enable",
      notify = Some "reload nginx config",
      file = Some {
        dest = "{{ nginxforward_path_enabled }}"
      , src = "{{ nginxforward_path_available }}"
      , state = "{% if nginxforward_enable %}link{% else %}absent{% endif %}"
    }
    }
]
