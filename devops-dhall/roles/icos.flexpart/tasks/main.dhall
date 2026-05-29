-- Auto-generated from ../../../../devops/roles/icos.flexpart/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      import_tasks = Some "flexpart_run.yml",
      tags = Some [ "flexpart_only", "flexpart_run" ],
      when = Some [ "flexpart_install_run is defined" ]
    }
  , Task::{
      import_tasks = Some "flexpart_ssh.yml",
      tags = Some [ "flexpart_only", "flexpart_ssh" ],
      when = Some [ "flexpart_ssh_users is defined" ]
    }
]
