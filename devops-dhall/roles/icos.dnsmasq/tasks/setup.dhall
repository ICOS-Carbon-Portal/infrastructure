-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : List Text })
    , copy : Optional ({ dest : Text, content : Text })
    , file : Optional ({ path : Text, state : Text })
  }
    , default =
        { apt = None ({ name : List Text })
    , copy = None ({ dest : Text, content : Text })
    , file = None ({ path : Text, state : Text })
  }
    }

in  [
    Task::{ name = "Install dnsmasq", apt = Some { name = [ "dnsmasq" ] } }
  , Task::{
      name = "Create /etc/default/dnsmasq.INSTANCE",
      copy = Some {
        dest = "/etc/default/dnsmasq.{{ dnsmasq_instance }}"
      , content = ''
        # We set this here so that'll be picked up by the etc/init.d/dnsmasq
        # script (which is used by the systemd service)
        CONFIG_DIR={{ dnsmasq_config_dir }}

        # If the resolvconf package is installed, dnsmasq will tell resolvconf
        # to use dnsmasq at 127.0.0.1 as the system's default resolver.
        # Uncommenting this line inhibits this behaviour.
        DNSMASQ_EXCEPT="lo"

      ''
    }
    }
  , Task::{
      name = "Create /etc/dnsmasq.INSTANCE.d directory",
      file = Some { path = "{{ dnsmasq_config_dir }}", state = "directory" }
    }
]
