-- Auto-generated from install.yml

let Task =
    { Type =
        { name : Text
    , `ansible.builtin.get_url` : Optional ({ url : Text, dest : Text, mode : Text, force : Bool })
    , apt_repository : Optional ({ filename : Text, repo : Text })
    , apt : Optional ({ name : Text, state : Text })
    , notify : Optional Text
    , shell : Optional Text
    , args : Optional ({ chdir : Text, creates : Text })
    , changed_when : Optional Bool
  }
    , default =
        { `ansible.builtin.get_url` = None ({ url : Text, dest : Text, mode : Text, force : Bool })
    , apt_repository = None ({ filename : Text, repo : Text })
    , apt = None ({ name : Text, state : Text })
    , notify = None Text
    , shell = None Text
    , args = None ({ chdir : Text, creates : Text })
    , changed_when = None Bool
  }
    }

in  [
    Task::{
      name = "Add caddy signing key",
      `ansible.builtin.get_url` = Some {
        url = "https://dl.cloudsmith.io/public/caddy/stable/gpg.key"
      , dest = "/etc/apt/trusted.gpg.d/caddy.asc"
      , mode = "0644"
      , force = True
    }
    }
  , Task::{
      name = "Add caddy apt repository",
      apt_repository = Some {
        filename = "caddy"
      , repo = "deb [signed-by=/etc/apt/trusted.gpg.d/caddy.asc] https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main"
    }
    }
  , Task::{
      name = "Install caddy",
      apt = Some { name = "caddy", state = "{{ 'latest' if caddy_upgrade else 'present' }}" },
      notify = Some "restart caddy"
    }
  , Task::{
      name = "Remove default config file",
      shell = Some ''
      head -1 Caddyfile | grep -q -F '# The Caddyfile is an easy way' \
        && mv Caddyfile Caddyfile.dist || :

    '',
      args = Some { chdir = "/etc/caddy", creates = "/etc/caddy/Caddyfile.dist" },
      changed_when = Some False
    }
]
