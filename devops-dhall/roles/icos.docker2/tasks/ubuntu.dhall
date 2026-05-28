-- Auto-generated from ubuntu.yml

let Entry =
    { Type =
        { name : Text
    , `ansible.builtin.get_url` : Optional ({ url : Text, dest : Text, mode : Text, force : Bool })
    , register : Optional Text
    , shellfact : Optional ({ exec : Text, fact : Text })
    , check_mode : Optional Bool
    , apt_repository : Optional ({ filename : Text, repo : Text })
  }
    , default =
        { `ansible.builtin.get_url` = None ({ url : Text, dest : Text, mode : Text, force : Bool })
    , register = None Text
    , shellfact = None ({ exec : Text, fact : Text })
    , check_mode = None Bool
    , apt_repository = None ({ filename : Text, repo : Text })
  }
    }

in  [
    Entry::{
      name = "Add docker key",
      `ansible.builtin.get_url` = Some {
        url = "https://download.docker.com/linux/ubuntu/gpg"
      , dest = "/etc/apt/trusted.gpg.d/docker.asc"
      , mode = "0644"
      , force = True
    },
      register = Some "_key"
    }
  , Entry::{
      name = "Retrieve deb_arch fact",
      shellfact = Some { exec = "dpkg --print-architecture", fact = "deb_arch" },
      check_mode = Some False
    }
  , Entry::{
      name = "Add docker apt repository",
      apt_repository = Some {
        filename = "docker"
      , repo = "deb [arch={{ deb_arch }} signed-by={{ _key.dest }}] https://download.docker.com/linux/ubuntu {{ ansible_lsb.codename }} stable"
    }
    }
]
