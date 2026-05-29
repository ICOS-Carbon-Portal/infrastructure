-- Auto-generated from remove.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove docker storage volume for {{ zfsdocker_name }}",
      zfs = Some {
        name = "pool/docker/{{ zfsdocker_name }}"
      , state = "absent"
      , extra_zfs_properties = None ({ volsize : Text })
    }
    }
]
