-- Auto-generated from xcaddy-debian.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add xcaddy key",
      `ansible.builtin.get_url` = Some {
        url = "https://dl.cloudsmith.io/public/caddy/xcaddy/gpg.key"
      , dest = "/etc/apt/trusted.gpg.d/xcaddy.asc"
      , mode = "0644"
      , force = True
    },
      register = Some "_key"
    }
  , Task::{
      name = Some "Add xcaddy apt repository",
      apt_repository = Some {
        filename = Some "xcaddy"
      , repo = "deb [signed-by={{ _key.dest }}] https://dl.cloudsmith.io/public/caddy/xcaddy/deb/debian any-version main"
    }
    }
  , Task::{
      name = Some "Install xcaddy",
      apt = Some {
        name = Some [ "xcaddy" ]
      , state = Some "{{ 'latest' if xcaddy_upgrade else 'present' }}"
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
      name = Some "Test that xcaddy works",
      shell = Some "xcaddy version",
      changed_when = Some "False"
    }
]
