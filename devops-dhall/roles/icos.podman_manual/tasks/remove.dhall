-- Auto-generated from remove.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ name : Text, state : Text })
    , apt : Optional ({ state : Text, purge : Bool, name : List Text })
    , shell : Optional Text
    , changed_when : Optional Bool
    , loop : Optional (List Text)
  }
    , default =
        { file = None ({ name : Text, state : Text })
    , apt = None ({ state : Text, purge : Bool, name : List Text })
    , shell = None Text
    , changed_when = None Bool
    , loop = None (List Text)
  }
    }

in  [
    Task::{
      name = "Remove podman docker wrapper",
      file = Some { name = "/usr/local/bin/docker", state = "absent" }
    }
  , Task::{
      name = "Purge podman requirements",
      apt = Some {
        state = "absent"
      , purge = True
      , name = [ "containers-storage", "podman", "buildah" ]
    }
    }
  , Task::{
      name = "Remove /etc/cni/net.d",
      file = Some { name = "/etc/cni/net.d", state = "absent" }
    }
  , Task::{
      name = "rmdir /etc/cni",
      shell = Some "rmdir --ignore-fail-on-non-empty /etc/cni || :",
      changed_when = Some False
    }
  , Task::{ name = "Remove /opt/cni", file = Some { name = "/opt/cni", state = "absent" } }
  , Task::{
      name = "Remove /etc/containers",
      file = Some { name = "/etc/containers", state = "absent" }
    }
  , Task::{
      name = "Remove /etc/bash_completion.d/podman",
      file = Some { name = "/etc/bash_completion.d/podman", state = "absent" }
    }
  , Task::{
      name = "Remove /etc/apt/preferences.d/podman",
      file = Some { name = "/etc/apt/preferences.d/podman", state = "absent" }
    }
  , Task::{
      name = "Remove podman binaries",
      file = Some { name = "{{ item }}", state = "absent" },
      loop = Some [ "/usr/local/bin/podman", "/usr/local/bin/podman-remote" ]
    }
]
