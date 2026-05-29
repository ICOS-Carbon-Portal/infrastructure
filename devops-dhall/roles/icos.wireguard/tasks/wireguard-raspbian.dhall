-- Auto-generated from ../../../../devops/roles/icos.wireguard/tasks/wireguard-raspbian.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add key for debian {{ ansible_lsb.release }}",
      apt_key = Some {
        id = None Text,
        url = "https://ftp-master.debian.org/keys/archive-key-{{ ansible_lsb.release}}.asc",
        state = "present"
    }
    }
  , Task::{
      name = Some "Add debian apt repository",
      apt_repository = Some {
        filename = Some "debian_unstable.list",
        repo = ''
        deb http://deb.debian.org/debian/ unstable main

      ''
    }
    }
  , Task::{
      name = Some "Set debian unstable packages to a lower priority",
      copy = Some {
        dest = "/etc/apt/preferences.d/debian_unstable",
        mode = None Text,
        content = Some ''
        Package: *
        Pin: release o=Debian,a=unstable
        Pin-Priority: 150

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
      name = Some "Install wireguard",
      apt = Some {
        name = Some [ "raspberrypi-kernel-headers", "wireguard" ],
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
