-- Auto-generated from ../../../../devops/roles/icos.podman_manual/tasks/remove.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove podman docker wrapper",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "/usr/local/bin/docker",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Purge podman requirements",
      apt = Some {
        name = Some [ "containers-storage", "podman", "buildah" ],
        state = Some "absent",
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = Some True,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Remove /etc/cni/net.d",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "/etc/cni/net.d",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "rmdir /etc/cni",
      shell = Some "rmdir --ignore-fail-on-non-empty /etc/cni || :",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
  , Task::{
      name = Some "Remove /opt/cni",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "/opt/cni",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Remove /etc/containers",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "/etc/containers",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Remove /etc/bash_completion.d/podman",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "/etc/bash_completion.d/podman",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Remove /etc/apt/preferences.d/podman",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "/etc/apt/preferences.d/podman",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Remove podman binaries",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "{{ item }}",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      loop = Some (Task.Poly_loop.Texts [ "/usr/local/bin/podman", "/usr/local/bin/podman-remote" ])
    }
]
