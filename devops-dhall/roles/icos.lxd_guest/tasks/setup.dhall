-- Auto-generated from ../../../../devops/roles/icos.lxd_guest/tasks/setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install packages",
      apt = Some {
        name = Some [ "iptables-persistent" ],
        state = None Text,
        update_cache = Some True,
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
      name = Some "Set timezone to Europe/Stockholm",
      timezone = Some { name = "Europe/Stockholm" },
      notify = Some [ "restart cron" ]
    }
  , Task::{
      name = Some "Generate locale",
      locale_gen = Some { name = "{{ item }}", state = "present" },
      loop = Some (Task.Poly_loop.Texts [ "en_US.UTF-8", "sv_SE.UTF-8" ])
    }
  , Task::{
      name = Some "Install public keys",
      authorized_key = Some {
        user = "root",
        key = "{{ lxd_guest_root_keys }}",
        state = Some "present",
        exclusive = Some True,
        key_options = None Text
    },
      when = Some [ "lxd_guest_root_keys is truthy" ]
    }
  , Task::{
      name = Some "Add default gateway as host",
      lineinfile = Some {
        path = "/etc/hosts",
        regex = Some "gateway.lxd$",
        line = Some "{{ ansible_default_ipv4.gateway }} gateway.lxd",
        state = Some "present",
        backrefs = None Bool,
        regexp = None Text,
        create = None Bool,
        owner = None Text,
        group = None Text,
        insertafter = None Text,
        mode = None Natural,
        insertbefore = None Text
    }
    }
  , Task::{ import_role = Some (Task.Poly_import_role.Str "name=icos.fail2ban") }
]
