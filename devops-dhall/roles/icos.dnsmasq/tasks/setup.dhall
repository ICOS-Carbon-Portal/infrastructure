-- Auto-generated from ../../../../devops/roles/icos.dnsmasq/tasks/setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install dnsmasq",
      apt = Some {
        name = Some [ "dnsmasq" ],
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
      name = Some "Create /etc/default/dnsmasq.INSTANCE",
      copy = Some {
        dest = "/etc/default/dnsmasq.{{ dnsmasq_instance }}",
        mode = None Text,
        content = Some ''
        # We set this here so that'll be picked up by the etc/init.d/dnsmasq
        # script (which is used by the systemd service)
        CONFIG_DIR={{ dnsmasq_config_dir }}

        # If the resolvconf package is installed, dnsmasq will tell resolvconf
        # to use dnsmasq at 127.0.0.1 as the system's default resolver.
        # Uncommenting this line inhibits this behaviour.
        DNSMASQ_EXCEPT="lo"

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Create /etc/dnsmasq.INSTANCE.d directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ dnsmasq_config_dir }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
]
