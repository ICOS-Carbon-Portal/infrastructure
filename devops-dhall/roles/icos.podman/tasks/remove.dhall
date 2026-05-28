-- Auto-generated from remove.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ state : Text, name : List Text })
    , file : Optional ({ name : Text, state : Text })
  }
    , default =
        { apt = None ({ state : Text, name : List Text })
    , file = None ({ name : Text, state : Text })
  }
    }

in  [
    Task::{
      name = "Uninstall podman",
      apt = Some {
        state = "absent"
      , name = [ "podman", "podman-plugins", "netavark", "containernetworking-plugins" ]
    }
    }
  , Task::{
      name = "Remove kubic key",
      file = Some { name = "/etc/apt/trusted.gpg.d/kubic.asc", state = "absent" }
    }
]
