-- Auto-generated from docker.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ dest : Text, mode : Text, content : Text })
    , file : Optional ({ dest : Text, src : Text, state : Text })
  }
    , default =
        { copy = None ({ dest : Text, mode : Text, content : Text })
    , file = None ({ dest : Text, src : Text, state : Text })
  }
    }

in  [
    Task::{
      name = "Create docker wrapper",
      copy = Some {
        dest = "/usr/local/bin/docker"
      , mode = "+x"
      , content = ''
        #!/bin/sh
        exec /usr/local/bin/podman "$@"

      ''
    }
    }
  , Task::{
      name = "Create /run/docker.sock symlink",
      file = Some { dest = "/run/docker.sock", src = "/run/podman/podman.sock", state = "link" }
    }
]
