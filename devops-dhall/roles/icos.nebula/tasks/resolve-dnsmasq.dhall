-- Auto-generated from resolve-dnsmasq.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : List Text })
    , copy : Optional ({ dest : Text, content : Text })
    , register : Optional Text
    , systemd : Optional ({ name : Text, state : Text })
  }
    , default =
        { apt = None ({ name : List Text })
    , copy = None ({ dest : Text, content : Text })
    , register = None Text
    , systemd = None ({ name : Text, state : Text })
  }
    }

in  [
    Task::{ name = "Install openresolv", apt = Some { name = [ "openresolv", "dnsmasq" ] } }
  , Task::{
      name = "Add nebula nameserver to dnsmasq",
      copy = Some {
        dest = "/etc/dnsmasq.d/nebula.conf"
      , content = ''
        {% for server in nebula_resolve_servers %}
        server=/nebula/{{server}}
        {% endfor %}

      ''
    },
      register = Some "_conf"
    }
  , Task::{
      name = "Make sure dnsmasq is (re)started",
      systemd = Some { name = "dnsmasq", state = "{{ 'restarted' if _conf.changed else 'started' }}" }
    }
]
