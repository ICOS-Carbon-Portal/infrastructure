-- Auto-generated from ../../../../devops/roles/icos.certbot/tasks/certbot.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "certbot_live.yml", when = Some [ "not certbot_fake_certificate" ] }
  , Task::{ import_tasks = Some "certbot_fake.yml", when = Some [ "certbot_fake_certificate" ] }
  , Task::{
      name = Some "Export certbot nginx config variable with prefix name",
      set_fact = Some (Task.Poly_set_fact.Str "{{ certbot_conf_name }}_certbot_nginx_conf=\"{{certbot_nginx_conf}}\"")
    }
]
