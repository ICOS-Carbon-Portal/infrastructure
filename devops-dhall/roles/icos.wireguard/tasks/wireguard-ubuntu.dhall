-- Auto-generated from ../../../../devops/roles/icos.wireguard/tasks/wireguard-ubuntu.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install wireguard",
      apt = Some {
        name = Some [ "wireguard" ],
        state = Some "present",
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
      name = Some "Create wireguard-reresolve-dns.sh symlink",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "link",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = Some "{{ wireguard_reresolve_script }}",
          recurse = None Bool,
          src = Some "/usr/share/doc/wireguard-tools/examples/reresolve-dns/reresolve-dns.sh"
      })
    }
  , Task::{
      name = Some "Making a note that wireguard is installed",
      set_fact = Some (Task.Poly_set_fact.Record {
          certbot_nginx_conf = None Text,
          destjarfile = None Text,
          name = None Text,
          nebula_resolve_type = None Text,
          cacheable = Some True,
          nebula_ssh_public = None Text,
          quince_tomcat_dir = None Text,
          sshlogin_src_user = None Text,
          sshlogin_dst_user = None Text,
          _wg_is_installed = Some 1
      })
    }
]
