-- Auto-generated from remove.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Uninstall podman",
      apt = Some {
        name = Some [ "podman", "podman-plugins", "netavark", "containernetworking-plugins" ]
      , state = Some "absent"
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Remove kubic key",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "/etc/apt/trusted.gpg.d/kubic.asc"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
]
