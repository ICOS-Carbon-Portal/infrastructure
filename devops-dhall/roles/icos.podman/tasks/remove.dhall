-- Auto-generated from ../../../../devops/roles/icos.podman/tasks/remove.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Uninstall podman",
      apt = Some {
        name = Some [ "podman", "podman-plugins", "netavark", "containernetworking-plugins" ],
        state = Some "absent",
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Remove kubic key",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "/etc/apt/trusted.gpg.d/kubic.asc",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
]
