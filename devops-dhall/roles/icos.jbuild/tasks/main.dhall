-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "jbuild.yml", tags = Some [ "jbuild_jbuild" ] }
  , Task::{ import_tasks = Some "users.yml", tags = Some [ "jbuild_users" ] }
  , Task::{
      import_tasks = Some "edctl.yml",
      tags = Some [ "jbuild_edctl" ],
      delegate_to = Some "{{ jbuild_edctl_host }}"
    }
  , Task::{
      import_tasks = Some "jyctl.yml",
      tags = Some [ "jbuild_jyctl" ],
      delegate_to = Some "{{ jbuild_jyctl_host }}"
    }
  , Task::{
      import_tasks = Some "rsync.yml",
      tags = Some [ "jbuild_rsync" ],
      delegate_to = Some "{{ jbuild_rsync_host }}"
    }
]
