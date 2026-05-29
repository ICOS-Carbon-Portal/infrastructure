-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create docker storage volume for {{ zfsdocker_name }}",
      zfs = Some {
        name = "pool/docker/{{ zfsdocker_name }}"
      , state = "present"
      , extra_zfs_properties = Some { volsize = "{{ zfsdocker_size }}" }
    }
    }
  , Task::{
      name = Some "Create a btrfs filesystem on {{ zfsdocker_name }}",
      tags = Some [ "zfs", "zfsdocker" ],
      filesystem = Some {
        dev = "{{ zfsdocker_zvol }}"
      , fstype = "btrfs"
      , opts = "-L docker_{{ zfsdocker_name }}"
    }
    }
  , Task::{
      name = Some "Change owner of btrfs filesystem",
      command = Some "unshare -m bash -c 'mount {{ zfsdocker_zvol }} /tmp; stat -c '%u:%g' /tmp; chown 1000000:1000000 /tmp'",
      register = Some "r",
      changed_when = Some "r.stdout != '1000000:1000000'",
      failed_when = Some "r.rc != 0"
    }
]
