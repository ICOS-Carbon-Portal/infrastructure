-- Auto-generated from remove.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove podman docker wrapper",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "/usr/local/bin/docker"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Purge podman requirements",
      apt = Some {
        name = Some [ "containers-storage", "podman", "buildah" ]
      , state = Some "absent"
      , update_cache = None Bool
      , deb = None Text
      , purge = Some True
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Remove /etc/cni/net.d",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "/etc/cni/net.d"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "rmdir /etc/cni",
      shell = Some "rmdir --ignore-fail-on-non-empty /etc/cni || :",
      changed_when = Some "False"
    }
  , Task::{
      name = Some "Remove /opt/cni",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "/opt/cni"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Remove /etc/containers",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "/etc/containers"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Remove /etc/bash_completion.d/podman",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "/etc/bash_completion.d/podman"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Remove /etc/apt/preferences.d/podman",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "/etc/apt/preferences.d/podman"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Remove podman binaries",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "{{ item }}"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    },
      loop = Some [ "/usr/local/bin/podman", "/usr/local/bin/podman-remote" ]
    }
]
