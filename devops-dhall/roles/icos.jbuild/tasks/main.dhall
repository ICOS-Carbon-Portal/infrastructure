-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Text
    , tags : Text
    , delegate_to : Optional Text
  }
    , default =
        { delegate_to = None Text
  }
    }

in  [
    Item::{ import_tasks = "jbuild.yml", tags = "jbuild_jbuild" }
  , Item::{ import_tasks = "users.yml", tags = "jbuild_users" }
  , Item::{
      import_tasks = "edctl.yml",
      tags = "jbuild_edctl",
      delegate_to = Some "{{ jbuild_edctl_host }}"
    }
  , Item::{
      import_tasks = "jyctl.yml",
      tags = "jbuild_jyctl",
      delegate_to = Some "{{ jbuild_jyctl_host }}"
    }
  , Item::{
      import_tasks = "rsync.yml",
      tags = "jbuild_rsync",
      delegate_to = Some "{{ jbuild_rsync_host }}"
    }
]
