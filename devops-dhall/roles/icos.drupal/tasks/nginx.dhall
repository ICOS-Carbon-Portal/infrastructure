-- Auto-generated from ../../../../devops/roles/icos.drupal/tasks/nginx.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ include_role = Some (Task.Poly_include_role.Str "name=icos.certbot") }
  , Task::{
      name = Some "Copy nginx {{ nginx_conf_name }}.conf",
      template = Some {
        src = "nginx.conf.j2",
        dest = "/etc/nginx/conf.d/{{ nginx_conf_name }}.conf",
        mode = Some "448",
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      notify = Some [ "reload nginx config" ]
    }
]
