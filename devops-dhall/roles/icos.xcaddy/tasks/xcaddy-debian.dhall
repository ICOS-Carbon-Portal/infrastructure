-- Auto-generated from xcaddy-debian.yml

let Task =
    { Type =
        { name : Text
    , `ansible.builtin.get_url` : Optional ({ url : Text, dest : Text, mode : Text, force : Bool })
    , register : Optional Text
    , apt_repository : Optional ({ filename : Text, repo : Text })
    , apt : Optional ({ name : Text, state : Text })
    , shell : Optional Text
    , changed_when : Optional Bool
  }
    , default =
        { `ansible.builtin.get_url` = None ({ url : Text, dest : Text, mode : Text, force : Bool })
    , register = None Text
    , apt_repository = None ({ filename : Text, repo : Text })
    , apt = None ({ name : Text, state : Text })
    , shell = None Text
    , changed_when = None Bool
  }
    }

in  [
    Task::{
      name = "Add xcaddy key",
      `ansible.builtin.get_url` = Some {
        url = "https://dl.cloudsmith.io/public/caddy/xcaddy/gpg.key"
      , dest = "/etc/apt/trusted.gpg.d/xcaddy.asc"
      , mode = "0644"
      , force = True
    },
      register = Some "_key"
    }
  , Task::{
      name = "Add xcaddy apt repository",
      apt_repository = Some {
        filename = "xcaddy"
      , repo = "deb [signed-by={{ _key.dest }}] https://dl.cloudsmith.io/public/caddy/xcaddy/deb/debian any-version main"
    }
    }
  , Task::{
      name = "Install xcaddy",
      apt = Some { name = "xcaddy", state = "{{ 'latest' if xcaddy_upgrade else 'present' }}" }
    }
  , Task::{
      name = "Test that xcaddy works",
      shell = Some "xcaddy version",
      changed_when = Some False
    }
]
