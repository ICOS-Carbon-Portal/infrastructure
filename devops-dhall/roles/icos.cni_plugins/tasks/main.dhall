-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create directory",
      file = Some {
        path = Some "{{ item }}"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    },
      loop = Some [ "/opt/cni/download", "/opt/cni/bin", "/etc/cni/net.d" ]
    }
  , Task::{
      name = Some "Find latest release of CNI networking plugins",
      check_mode = Some False,
      delegate_to = Some "localhost",
      run_once = Some True,
      github_release = Some { user = "containernetworking", repo = "plugins", action = "latest_release" },
      register = Some "podman_release"
    }
  , Task::{
      name = Some "Download cni plugins",
      get_url = Some {
        url = "{{ cni_plugin_url }}"
      , dest = "/opt/cni/download/plugins.tgz"
      , force = None Text
      , mode = None Text
    }
    }
  , Task::{
      name = Some "Unarchive cni plugins",
      unarchive = Some {
        src = "/opt/cni/download/plugins.tgz"
      , dest = "/opt/cni/bin"
      , remote_src = True
      , owner = None Text
      , group = None Text
      , include = None (List Text)
      , list_files = None Bool
      , extra_opts = None (List Text)
      , mode = None Text
      , creates = None Text
    },
      diff = Some False
    }
  , Task::{
      name = Some "Create default network configuration",
      copy = Some {
        src = Some "87-podman-bridge.conflist"
      , dest = "/etc/cni/net.d/"
      , mode = None Text
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
]
