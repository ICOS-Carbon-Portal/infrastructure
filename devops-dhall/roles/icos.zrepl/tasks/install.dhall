-- Auto-generated from install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add zrepl key",
      `ansible.builtin.get_url` = Some {
        url = "https://zrepl.cschwarz.com/apt/apt-key.asc"
      , dest = "/etc/apt/trusted.gpg.d/zrepl.asc"
      , mode = "0644"
      , force = True
    },
      register = Some "_key"
    }
  , Task::{
      name = Some "Add zrepl apt repository",
      apt_repository = Some {
        filename = Some "zrepl"
      , repo = "deb [arch=amd64 signed-by={{ _key.dest }}] https://zrepl.cschwarz.com/apt/{{ ansible_lsb.id | lower }} {{ ansible_lsb.codename }} main"
    }
    }
  , Task::{
      name = Some "Install zrepl",
      apt = Some {
        name = Some [ "zrepl" ]
      , state = None Text
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
      name = Some "Set permissions on /etc/zrepl",
      file = Some {
        path = Some "/etc/zrepl"
      , state = Some "directory"
      , mode = Some "0700"
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
]
