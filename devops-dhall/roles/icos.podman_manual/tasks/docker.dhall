-- Auto-generated from ../../../../devops/roles/icos.podman_manual/tasks/docker.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create docker wrapper",
      copy = Some {
        dest = "/usr/local/bin/docker",
        mode = Some "+x",
        content = Some ''
        #!/bin/sh
        exec /usr/local/bin/podman "$@"

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
      name = Some "Create /run/docker.sock symlink",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "link",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = Some "/run/docker.sock",
          recurse = None Bool,
          src = Some "/run/podman/podman.sock"
      })
    }
]
