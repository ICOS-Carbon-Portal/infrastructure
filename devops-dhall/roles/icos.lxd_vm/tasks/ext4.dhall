-- Auto-generated from ../../../../devops/roles/icos.lxd_vm/tasks/ext4.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ name = Some "Include vars for ext4", include_vars = Some "ext4.yml" }
  , Task::{
      name = Some "Create {{ lxd_vm_root_pool }} storage pool",
      tags = Some [ "pool" ],
      shell = Some ''
      /snap/bin/lxc storage show {{ lxd_vm_root_pool }} > /dev/null 2>&1 || \ /snap/bin/lxc storage create {{ lxd_vm_root_pool }} \
                            btrfs size={{ lxd_vm_root_size }}

    '',
      register = Some "_r",
      changed_when = Some (Task.Poly_changed_when.Texts [ "(\"Storage pool %s created\" % lxd_vm_root_pool) in _r.stdout" ])
    }
]
