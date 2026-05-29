-- Auto-generated from setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install dnsmasq",
      apt = Some {
        name = Some [ "dnsmasq" ]
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
      name = Some "Create /etc/default/dnsmasq.INSTANCE",
      copy = Some {
        src = None Text
      , dest = "/etc/default/dnsmasq.{{ dnsmasq_instance }}"
      , mode = None Text
      , content = Some ''
        # We set this here so that'll be picked up by the etc/init.d/dnsmasq
        # script (which is used by the systemd service)
        CONFIG_DIR={{ dnsmasq_config_dir }}

        # If the resolvconf package is installed, dnsmasq will tell resolvconf
        # to use dnsmasq at 127.0.0.1 as the system's default resolver.
        # Uncommenting this line inhibits this behaviour.
        DNSMASQ_EXCEPT="lo"

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Create /etc/dnsmasq.INSTANCE.d directory",
      file = Some {
        path = Some "{{ dnsmasq_config_dir }}"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
]
