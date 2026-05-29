-- Auto-generated from ../../../../devops/roles/icos.caddy/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "install.yml" }
  , Task::{ import_tasks = Some "just.yml", tags = Some [ "caddy_just" ] }
  , Task::{
      name = Some "Install plain caddy",
      include_tasks = Some (Task.Poly_include_tasks.Str "plain.yml"),
      when = Some [ "not caddy_modules" ]
    }
  , Task::{
      include_tasks = Some (Task.Poly_include_tasks.Record { file = "xcaddy.yml", apply = Some { tags = "caddy_modules" } }),
      tags = Some [ "caddy_xcaddy" ],
      when = Some [ "caddy_modules" ]
    }
  , Task::{
      name = Some "Check that caddy was properly installed",
      `ansible.builtin.shell` = Some (Task.Poly_ansible_builtin_shell.Str "{{ caddy_bin }} version"),
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
  , Task::{
      name = Some "Set caddy global configuration",
      include_tasks = Some (Task.Poly_include_tasks.Str "global.yml")
    }
  , Task::{
      name = Some "Configure caddy site",
      include_tasks = Some (Task.Poly_include_tasks.Record { file = "site.yml", apply = Some { tags = "caddy_site" } }),
      tags = Some [ "caddy_site" ],
      when = Some [ "caddy_name is defined" ]
    }
]
