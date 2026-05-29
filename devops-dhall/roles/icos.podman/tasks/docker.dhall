-- Auto-generated from docker.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create docker wrapper",
      copy = Some {
        src = None Text
      , dest = "/usr/local/bin/docker"
      , mode = Some "+x"
      , content = Some ''
        #!/bin/sh
        exec /usr/local/bin/podman "$@"

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Create /run/docker.sock symlink",
      file = Some {
        path = None Text
      , state = Some "link"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = Some "/run/docker.sock"
      , recurse = None Bool
      , src = Some "/run/podman/podman.sock"
    }
    }
]
