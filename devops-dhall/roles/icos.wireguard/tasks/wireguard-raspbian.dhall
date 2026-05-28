-- Auto-generated from wireguard-raspbian.yml

let Task =
    { Type =
        { name : Text
    , apt_key : Optional ({ url : Text, state : Text })
    , apt_repository : Optional ({ filename : Text, repo : Text })
    , copy : Optional ({ dest : Text, content : Text })
    , apt : Optional ({ name : List Text, state : Text })
    , file : Optional ({ dest : Text, src : Text, state : Text })
    , set_fact : Optional ({ _wg_is_installed : Natural, cacheable : Bool })
  }
    , default =
        { apt_key = None ({ url : Text, state : Text })
    , apt_repository = None ({ filename : Text, repo : Text })
    , copy = None ({ dest : Text, content : Text })
    , apt = None ({ name : List Text, state : Text })
    , file = None ({ dest : Text, src : Text, state : Text })
    , set_fact = None ({ _wg_is_installed : Natural, cacheable : Bool })
  }
    }

in  [
    Task::{
      name = "Add key for debian {{ ansible_lsb.release }}",
      apt_key = Some {
        url = "https://ftp-master.debian.org/keys/archive-key-{{ ansible_lsb.release}}.asc"
      , state = "present"
    }
    }
  , Task::{
      name = "Add debian apt repository",
      apt_repository = Some {
        filename = "debian_unstable.list"
      , repo = ''
        deb http://deb.debian.org/debian/ unstable main

      ''
    }
    }
  , Task::{
      name = "Set debian unstable packages to a lower priority",
      copy = Some {
        dest = "/etc/apt/preferences.d/debian_unstable"
      , content = ''
        Package: *
        Pin: release o=Debian,a=unstable
        Pin-Priority: 150

      ''
    }
    }
  , Task::{
      name = "Install wireguard",
      apt = Some { name = [ "raspberrypi-kernel-headers", "wireguard" ], state = "present" }
    }
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
