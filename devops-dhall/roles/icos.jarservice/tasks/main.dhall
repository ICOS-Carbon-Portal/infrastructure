-- Auto-generated from ../../../../devops/roles/icos.jarservice/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add {{ username }} user",
      user = Some {
        name = "{{ username }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = Some "/bin/bash",
        home = None Text,
        password_lock = None Bool,
        groups = Some [ "{{ extra_groups }}" ],
        append = Some "True",
        state = None Text,
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = None Text
    },
      register = Some "_user"
    }
  , Task::{
      include_tasks = Some (Task.Poly_include_tasks.Str "jarfile.yml"),
      when = Some [ "not (jarservice_conf_only | default(False) | bool)" ]
    }
  , Task::{
      name = Some "Copy {{ servicename }} config file {{ configfile }}",
      template = Some {
        src = "{{ configfile }}",
        dest = "{{ _user.home}}/",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      notify = Some [ "restart {{ servicename }}" ]
    }
  , Task::{
      name = Some "Copy {{ servicename }} nginx config file(s) {{nginxconfig}}*",
      template = Some {
        src = "{{ item }}",
        dest = "/etc/nginx/conf.d/",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      with_fileglob = Some [ "{{nginxconfig}}*" ],
      when = Some [ "nginxconfig is defined and not certbot_disabled" ],
      notify = Some [ "reload nginx config" ]
    }
  , Task::{
      name = Some "Add systemd {{ servicename }} servicefile",
      template = Some {
        src = "{{ servicetemplate }}",
        dest = "/etc/systemd/system/{{ servicename }}.service",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      notify = Some [ "reload systemd config" ]
    }
  , Task::{
      name = Some "Enable systemd {{ servicename }}",
      service = Some (Task.Poly_service.Str "name={{ servicename }} enabled=yes state=started")
    }
]
