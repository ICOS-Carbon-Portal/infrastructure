-- Auto-generated from configure.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ dest : Text, content : Text })
    , `ansible.posix.synchronize` : Optional ({ src : Text, dest : Text, owner : Bool, group : Bool })
    , command : Optional Text
    , args : Optional ({ creates : Text })
    , import_tasks : Optional Text
    , when : Optional (List Text)
  }
    , default =
        { copy = None ({ dest : Text, content : Text })
    , `ansible.posix.synchronize` = None ({ src : Text, dest : Text, owner : Bool, group : Bool })
    , command = None Text
    , args = None ({ creates : Text })
    , import_tasks = None Text
    , when = None (List Text)
  }
    }

in  [
    Task::{
      name = "Block podman from being apt-installed",
      copy = Some {
        dest = "/etc/apt/preferences.d/podman"
      , content = ''
        Package: podman
        Pin: release *
        Pin-Priority: -1

      ''
    }
    }
  , Task::{
      name = "Synchronize configuration files to /etc/containers",
      `ansible.posix.synchronize` = Some {
        src = "containers"
      , dest = "/etc/"
      , owner = False
      , group = False
    }
    }
  , Task::{
      name = "Setup bash completion for podman",
      command = Some "podman completion -f /etc/bash_completion.d/podman bash",
      args = Some { creates = "/etc/bash_completion.d/podman" }
    }
  , Task::{
      name = "Configure storage for LXD + ZFS",
      import_tasks = Some "zfs-and-lxd.yml",
      when = Some [ "icos.inside_lxd", "icos.root_is_zfs" ]
    }
]
