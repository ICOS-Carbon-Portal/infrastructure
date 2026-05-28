-- Auto-generated from wireguard-raspbian-zero.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : List Text })
    , git : Optional ({ repo : Text, version : Text, dest : Text, update : Text })
    , diff : Optional Bool
    , command : Optional Text
    , args : Optional ({ chdir : Text, creates : Text })
    , register : Optional Text
    , failed_when : Optional Text
    , file : Optional ({ dest : Text, src : Text, state : Text })
    , set_fact : Optional ({ _wg_is_installed : Natural, cacheable : Bool })
  }
    , default =
        { apt = None ({ name : List Text })
    , git = None ({ repo : Text, version : Text, dest : Text, update : Text })
    , diff = None Bool
    , command = None Text
    , args = None ({ chdir : Text, creates : Text })
    , register = None Text
    , failed_when = None Text
    , file = None ({ dest : Text, src : Text, state : Text })
    , set_fact = None ({ _wg_is_installed : Natural, cacheable : Bool })
  }
    }

in  [
    Task::{
      name = "Install build tools",
      apt = Some {
        name = [
          "raspberrypi-kernel-headers"
        , "libmnl-dev"
        , "libelf-dev"
        , "build-essential"
        , "git"
      ]
    }
    }
  , Task::{
      name = "Clone wireguard-linux-compat",
      git = Some {
        repo = "https://git.zx2c4.com/wireguard-linux-compat"
      , version = "master"
      , dest = "/root/wireguard-linux-compat"
      , update = "{{ wireguard_update }}"
    },
      diff = Some False
    }
  , Task::{
      name = "Clone wireguard-tools",
      git = Some {
        repo = "https://git.zx2c4.com/wireguard-tools"
      , version = "master"
      , dest = "/root/wireguard-tools"
      , update = "{{ wireguard_update }}"
    },
      diff = Some False
    }
  , Task::{
      name = "Compile and install wireguard-linux-compat",
      command = Some "make all install",
      args = Some {
        chdir = "/root/wireguard-linux-compat/src"
      , creates = "/root/wireguard-linux-compat/src/wireguard.ko"
    },
      register = Some "_r",
      failed_when = Some "_r.rc != 0"
    }
  , Task::{
      name = "Compile and install wireguard-tools",
      command = Some "make all install",
      args = Some { chdir = "/root/wireguard-tools/src", creates = "/usr/bin/wg" },
      register = Some "_r",
      failed_when = Some "_r.rc != 0"
    }
  , Task::{
      name = "Create wireguard-reresolve-dns.sh symlink",
      file = Some {
        dest = "{{ wireguard_reresolve_script }}"
      , src = "/root/wireguard-tools/contrib/reresolve-dns/reresolve-dns.sh"
      , state = "link"
    }
    }
  , Task::{
      name = "Making a note that wireguard is installed",
      set_fact = Some { _wg_is_installed = 1, cacheable = True }
    }
]
