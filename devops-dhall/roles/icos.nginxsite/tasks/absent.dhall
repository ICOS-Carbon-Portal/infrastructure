-- Auto-generated from ../../../../devops/roles/icos.nginxsite/tasks/absent.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some [ "vars[item] is undefined" ],
      loop = Some (Task.Poly_loop.Texts [ "nginxsite_name" ])
    }
  , Task::{
      name = Some "Remove config file",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = Some "{{ item }}",
          recurse = None Bool,
          src = None Text
      }),
      loop = Some (Task.Poly_loop.Texts [
          "{{ nginxsite_path_enable }}"
        , "{{ nginxsite_path_available }}"
        , "{{ nginxsite_path_confd }}"
      ])
    }
  , Task::{
      name = Some "Reload nginx",
      systemd = Some {
        name = Some "nginx",
        state = Some "reloaded",
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    },
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
]
