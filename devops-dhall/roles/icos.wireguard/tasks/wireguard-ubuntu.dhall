-- Auto-generated from wireguard-ubuntu.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : Text, state : Text })
    , file : Optional ({ dest : Text, src : Text, state : Text })
    , set_fact : Optional ({ _wg_is_installed : Natural, cacheable : Bool })
  }
    , default =
        { apt = None ({ name : Text, state : Text })
    , file = None ({ dest : Text, src : Text, state : Text })
    , set_fact = None ({ _wg_is_installed : Natural, cacheable : Bool })
  }
    }

in  [
    Task::{ name = "Install wireguard", apt = Some { name = "wireguard", state = "present" } }
  , Task::{
      name = "Create wireguard-reresolve-dns.sh symlink",
      file = Some {
        dest = "{{ wireguard_reresolve_script }}"
      , src = "/usr/share/doc/wireguard-tools/examples/reresolve-dns/reresolve-dns.sh"
      , state = "link"
    }
    }
  , Task::{
      name = "Making a note that wireguard is installed",
      set_fact = Some { _wg_is_installed = 1, cacheable = True }
    }
]
