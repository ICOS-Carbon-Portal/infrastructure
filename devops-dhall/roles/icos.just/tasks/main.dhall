-- Auto-generated from ../../../../devops/roles/icos.just/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check whether just is installed",
      stat = Some { path = "/usr/local/bin/just" },
      register = Some "_r"
    }
  , Task::{
      name = Some "Install/upgrade just",
      include_tasks = Some (Task.Poly_include_tasks.Record { file = "install.yml", apply = None (({ tags : Text })) }),
      when = Some [ "not _r.stat.exists or just_upgrade" ]
    }
  , Task::{
      name = Some "Create bash_completion.d directory",
      file = Some (Task.Poly_file.Record {
          path = Some "/etc/bash_completion.d",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Add bash completions for just",
      `ansible.builtin.shell` = Some (Task.Poly_ansible_builtin_shell.Str ''
        just --completions bash > /etc/bash_completion.d/just

      ''),
      args = Some {
        chdir = None Text,
        creates = Some "/etc/bash_completion.d/just",
        executable = Some "/bin/bash",
        removes = None Text
    }
    }
]
