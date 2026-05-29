-- Auto-generated from configure.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Block podman from being apt-installed",
      copy = Some {
        src = None Text
      , dest = "/etc/apt/preferences.d/podman"
      , mode = None Text
      , content = Some ''
        Package: podman
        Pin: release *
        Pin-Priority: -1

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Synchronize configuration files to /etc/containers",
      `ansible.posix.synchronize` = Some {
        src = "containers"
      , dest = "/etc/"
      , owner = False
      , group = False
      , rsync_opts = None (List Text)
      , delete = None Bool
    }
    }
  , Task::{
      name = Some "Setup bash completion for podman",
      command = Some "podman completion -f /etc/bash_completion.d/podman bash",
      args = Some {
        creates = Some "/etc/bash_completion.d/podman"
      , chdir = None Text
      , executable = None Text
      , removes = None Text
    }
    }
  , Task::{
      name = Some "Configure storage for LXD + ZFS",
      import_tasks = Some "zfs-and-lxd.yml",
      when = Some [ "icos.inside_lxd", "icos.root_is_zfs" ]
    }
]
