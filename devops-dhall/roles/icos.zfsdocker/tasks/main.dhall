-- Auto-generated from ../../../../devops/roles/icos.zfsdocker/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create docker storage volume for {{ zfsdocker_name }}",
      zfs = Some {
        name = "pool/docker/{{ zfsdocker_name }}",
        state = "present",
        extra_zfs_properties = Some {
          mountpoint = None Text,
          quota = None Text,
          refquota = None Text,
          volsize = Some "{{ zfsdocker_size }}"
      }
    }
    }
  , Task::{
      name = Some "Create a btrfs filesystem on {{ zfsdocker_name }}",
      tags = Some [ "zfs", "zfsdocker" ],
      filesystem = Some {
        dev = "{{ zfsdocker_zvol }}",
        fstype = "btrfs",
        opts = "-L docker_{{ zfsdocker_name }}"
    }
    }
  , Task::{
      name = Some "Change owner of btrfs filesystem",
      command = Some "unshare -m bash -c 'mount {{ zfsdocker_zvol }} /tmp; stat -c '%u:%g' /tmp; chown 1000000:1000000 /tmp'",
      register = Some "r",
      changed_when = Some (Task.Poly_changed_when.Str "r.stdout != '1000000:1000000'"),
      failed_when = Some (Task.Poly_failed_when.Str "r.rc != 0")
    }
]
