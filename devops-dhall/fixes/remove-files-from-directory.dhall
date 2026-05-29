-- Auto-generated from ../../devops/fixes/remove-files-from-directory.yml

let Task = ../types/Task.dhall

in  [
    {
      hosts = "all"
    , tasks = [
        Task::{
          name = Some "Remove files from /opt/downloads",
          `ansible.builtin.shell` = Some (Task.Poly_ansible_builtin_shell.Str ''
            find . -maxdepth 1 -type f -exec rm '{}' ';'

          ''),
          args = Some {
            chdir = Some "/opt/downloads",
            creates = None Text,
            executable = Some "/bin/bash",
            removes = None Text
        }
        }
    ]
  }
]
