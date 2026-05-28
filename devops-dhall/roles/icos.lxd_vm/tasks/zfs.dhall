-- Auto-generated from zfs.yml

let Task =
    { Type =
        { name : Text
    , include_vars : Optional Text
    , when : Optional Text
    , import_role : Optional ({ name : Text })
    , vars : Optional ({ zfsdocker_size : Text })
  }
    , default =
        { include_vars = None Text
    , when = None Text
    , import_role = None ({ name : Text })
    , vars = None ({ zfsdocker_size : Text })
  }
    }

in  [
    Task::{ name = "Include vars for zfs", include_vars = Some "zfs.yml" }
  , Task::{
      name = "Create docker storage for LXD",
      when = Some "lxd_vm_docker",
      import_role = Some { name = "icos.zfsdocker" },
      vars = Some { zfsdocker_size = "{{ lxd_vm_docker_size }}" }
    }
]
