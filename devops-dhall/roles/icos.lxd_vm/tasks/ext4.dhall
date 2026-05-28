-- Auto-generated from ext4.yml

let Task =
    { Type =
        { name : Text
    , include_vars : Optional Text
    , tags : Optional Text
    , shell : Optional Text
    , register : Optional Text
    , changed_when : Optional (List Text)
  }
    , default =
        { include_vars = None Text
    , tags = None Text
    , shell = None Text
    , register = None Text
    , changed_when = None (List Text)
  }
    }

in  [
    Task::{ name = "Include vars for ext4", include_vars = Some "ext4.yml" }
  , Task::{
      name = "Create {{ lxd_vm_root_pool }} storage pool",
      tags = Some "pool",
      shell = Some ''
      /snap/bin/lxc storage show {{ lxd_vm_root_pool }} > /dev/null 2>&1 || \ /snap/bin/lxc storage create {{ lxd_vm_root_pool }} \
                            btrfs size={{ lxd_vm_root_size }}

    '',
      register = Some "_r",
      changed_when = Some [ "(\"Storage pool %s created\" % lxd_vm_root_pool) in _r.stdout" ]
    }
]
