-- Auto-generated from ../../../../devops/roles/icos.podman_manual/tasks/configure.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Block podman from being apt-installed",
      copy = Some {
        dest = "/etc/apt/preferences.d/podman",
        mode = None Text,
        content = Some ''
        Package: podman
        Pin: release *
        Pin-Priority: -1

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Synchronize configuration files to /etc/containers",
      `ansible.posix.synchronize` = Some {
        mode = None Text,
        copy_links = None Bool,
        src = "containers",
        dest = "/etc/",
        rsync_opts = None ((List Text)),
        owner = Some False,
        group = Some False,
        perms = None Bool,
        delete = None Bool
    }
    }
  , Task::{
      name = Some "Setup bash completion for podman",
      command = Some "podman completion -f /etc/bash_completion.d/podman bash",
      args = Some {
        chdir = None Text,
        creates = Some "/etc/bash_completion.d/podman",
        executable = None Text,
        removes = None Text
    }
    }
  , Task::{
      name = Some "Configure storage for LXD + ZFS",
      import_tasks = Some "zfs-and-lxd.yml",
      when = Some [ "icos.inside_lxd", "icos.root_is_zfs" ]
    }
]
