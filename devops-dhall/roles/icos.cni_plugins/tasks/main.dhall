-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text })
    , loop : Optional (List Text)
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , run_once : Optional Bool
    , github_release : Optional ({ user : Text, repo : Text, action : Text })
    , register : Optional Text
    , get_url : Optional ({ url : Text, dest : Text })
    , unarchive : Optional ({ src : Text, dest : Text, remote_src : Bool })
    , diff : Optional Bool
    , copy : Optional ({ src : Text, dest : Text })
  }
    , default =
        { file = None ({ path : Text, state : Text })
    , loop = None (List Text)
    , check_mode = None Bool
    , delegate_to = None Text
    , run_once = None Bool
    , github_release = None ({ user : Text, repo : Text, action : Text })
    , register = None Text
    , get_url = None ({ url : Text, dest : Text })
    , unarchive = None ({ src : Text, dest : Text, remote_src : Bool })
    , diff = None Bool
    , copy = None ({ src : Text, dest : Text })
  }
    }

in  [
    Task::{
      name = "Create directory",
      file = Some { path = "{{ item }}", state = "directory" },
      loop = Some [ "/opt/cni/download", "/opt/cni/bin", "/etc/cni/net.d" ]
    }
  , Task::{
      name = "Find latest release of CNI networking plugins",
      check_mode = Some False,
      delegate_to = Some "localhost",
      run_once = Some True,
      github_release = Some { user = "containernetworking", repo = "plugins", action = "latest_release" },
      register = Some "podman_release"
    }
  , Task::{
      name = "Download cni plugins",
      get_url = Some { url = "{{ cni_plugin_url }}", dest = "/opt/cni/download/plugins.tgz" }
    }
  , Task::{
      name = "Unarchive cni plugins",
      unarchive = Some { src = "/opt/cni/download/plugins.tgz", dest = "/opt/cni/bin", remote_src = True },
      diff = Some False
    }
  , Task::{
      name = "Create default network configuration",
      copy = Some { src = "87-podman-bridge.conflist", dest = "/etc/cni/net.d/" }
    }
]
