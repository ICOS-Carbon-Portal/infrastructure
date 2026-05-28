-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : { volsize : Text } })
    , tags : Optional (List Text)
    , filesystem : Optional ({ dev : Text, fstype : Text, opts : Text })
    , command : Optional Text
    , register : Optional Text
    , changed_when : Optional Text
    , failed_when : Optional Text
  }
    , default =
        { zfs = None ({ name : Text, state : Text, extra_zfs_properties : { volsize : Text } })
    , tags = None (List Text)
    , filesystem = None ({ dev : Text, fstype : Text, opts : Text })
    , command = None Text
    , register = None Text
    , changed_when = None Text
    , failed_when = None Text
  }
    }

in  [
    Entry::{
      name = "Create docker storage volume for {{ zfsdocker_name }}",
      zfs = Some {
        name = "pool/docker/{{ zfsdocker_name }}"
      , state = "present"
      , extra_zfs_properties = { volsize = "{{ zfsdocker_size }}" }
    }
    }
  , Entry::{
      name = "Create a btrfs filesystem on {{ zfsdocker_name }}",
      tags = Some [ "zfs", "zfsdocker" ],
      filesystem = Some {
        dev = "{{ zfsdocker_zvol }}"
      , fstype = "btrfs"
      , opts = "-L docker_{{ zfsdocker_name }}"
    }
    }
  , Entry::{
      name = "Change owner of btrfs filesystem",
      command = Some "unshare -m bash -c 'mount {{ zfsdocker_zvol }} /tmp; stat -c '%u:%g' /tmp; chown 1000000:1000000 /tmp'",
      register = Some "r",
      changed_when = Some "r.stdout != '1000000:1000000'",
      failed_when = Some "r.rc != 0"
    }
]
