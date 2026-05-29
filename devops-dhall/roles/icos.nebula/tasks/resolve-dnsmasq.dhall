-- Auto-generated from ../../../../devops/roles/icos.nebula/tasks/resolve-dnsmasq.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install openresolv",
      apt = Some {
        name = Some [ "openresolv", "dnsmasq" ],
        state = None Text,
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Add nebula nameserver to dnsmasq",
      copy = Some {
        dest = "/etc/dnsmasq.d/nebula.conf",
        mode = None Text,
        content = Some ''
        {% for server in nebula_resolve_servers %}
        server=/nebula/{{server}}
        {% endfor %}

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      register = Some "_conf"
    }
  , Task::{
      name = Some "Make sure dnsmasq is (re)started",
      systemd = Some {
        name = Some "dnsmasq",
        state = Some "{{ 'restarted' if _conf.changed else 'started' }}",
        daemon_reload = None Bool,
        enabled = None Text,
        `daemon-reload` = None Text,
        status = None Text
    }
    }
]
