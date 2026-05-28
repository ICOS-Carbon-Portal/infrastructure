-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , user : Optional ({ name : Text, groups : Text, append : Bool, shell : Text })
    , register : Optional Text
    , include_tasks : Optional Text
    , when : Optional Text
    , template : Optional ({ src : Text, dest : Text })
    , notify : Optional (List Text)
    , with_fileglob : Optional (List Text)
    , service : Optional Text
  }
    , default =
        { name = None Text
    , user = None ({ name : Text, groups : Text, append : Bool, shell : Text })
    , register = None Text
    , include_tasks = None Text
    , when = None Text
    , template = None ({ src : Text, dest : Text })
    , notify = None (List Text)
    , with_fileglob = None (List Text)
    , service = None Text
  }
    }

in  [
    Item::{
      name = Some "Add {{ username }} user",
      user = Some {
        name = "{{ username }}"
      , groups = "{{ extra_groups }}"
      , append = True
      , shell = "/bin/bash"
    },
      register = Some "_user"
    }
  , Item::{
      include_tasks = Some "jarfile.yml",
      when = Some "not (jarservice_conf_only | default(False) | bool)"
    }
  , Item::{
      name = Some "Copy {{ servicename }} config file {{ configfile }}",
      template = Some { src = "{{ configfile }}", dest = "{{ _user.home}}/" },
      notify = Some [ "restart {{ servicename }}" ]
    }
  , Item::{
      name = Some "Copy {{ servicename }} nginx config file(s) {{nginxconfig}}*",
      when = Some "nginxconfig is defined and not certbot_disabled",
      template = Some { src = "{{ item }}", dest = "/etc/nginx/conf.d/" },
      notify = Some [ "reload nginx config" ],
      with_fileglob = Some [ "{{nginxconfig}}*" ]
    }
  , Item::{
      name = Some "Add systemd {{ servicename }} servicefile",
      template = Some {
        src = "{{ servicetemplate }}"
      , dest = "/etc/systemd/system/{{ servicename }}.service"
    },
      notify = Some [ "reload systemd config" ]
    }
  , Item::{
      name = Some "Enable systemd {{ servicename }}",
      service = Some "name={{ servicename }} enabled=yes state=started"
    }
]
