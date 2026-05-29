-- Auto-generated from install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add caddy signing key",
      `ansible.builtin.get_url` = Some {
        url = "https://dl.cloudsmith.io/public/caddy/stable/gpg.key"
      , dest = "/etc/apt/trusted.gpg.d/caddy.asc"
      , mode = "0644"
      , force = True
    }
    }
  , Task::{
      name = Some "Add caddy apt repository",
      apt_repository = Some {
        filename = Some "caddy"
      , repo = "deb [signed-by=/etc/apt/trusted.gpg.d/caddy.asc] https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main"
    }
    }
  , Task::{
      name = Some "Install caddy",
      apt = Some {
        name = Some [ "caddy" ]
      , state = Some "{{ 'latest' if caddy_upgrade else 'present' }}"
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    },
      notify = Some [ "restart caddy" ]
    }
  , Task::{
      name = Some "Remove default config file",
      shell = Some ''
      head -1 Caddyfile | grep -q -F '# The Caddyfile is an easy way' \
        && mv Caddyfile Caddyfile.dist || :

    '',
      args = Some {
        creates = Some "/etc/caddy/Caddyfile.dist"
      , chdir = Some "/etc/caddy"
      , executable = None Text
      , removes = None Text
    },
      changed_when = Some "False"
    }
]
