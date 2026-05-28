-- Auto-generated from install.yml

let Task =
    { Type =
        { name : Text
    , `ansible.builtin.get_url` : Optional ({ url : Text, dest : Text, mode : Text, force : Bool })
    , register : Optional Text
    , apt_repository : Optional ({ filename : Text, repo : Text })
    , apt : Optional ({ name : Text })
    , file : Optional ({ path : Text, state : Text, mode : Text })
  }
    , default =
        { `ansible.builtin.get_url` = None ({ url : Text, dest : Text, mode : Text, force : Bool })
    , register = None Text
    , apt_repository = None ({ filename : Text, repo : Text })
    , apt = None ({ name : Text })
    , file = None ({ path : Text, state : Text, mode : Text })
  }
    }

in  [
    Task::{
      name = "Add zrepl key",
      `ansible.builtin.get_url` = Some {
        url = "https://zrepl.cschwarz.com/apt/apt-key.asc"
      , dest = "/etc/apt/trusted.gpg.d/zrepl.asc"
      , mode = "0644"
      , force = True
    },
      register = Some "_key"
    }
  , Task::{
      name = "Add zrepl apt repository",
      apt_repository = Some {
        filename = "zrepl"
      , repo = "deb [arch=amd64 signed-by={{ _key.dest }}] https://zrepl.cschwarz.com/apt/{{ ansible_lsb.id | lower }} {{ ansible_lsb.codename }} main"
    }
    }
  , Task::{ name = "Install zrepl", apt = Some { name = "zrepl" } }
  , Task::{
      name = "Set permissions on /etc/zrepl",
      file = Some { path = "/etc/zrepl", state = "directory", mode = "0700" }
    }
]
