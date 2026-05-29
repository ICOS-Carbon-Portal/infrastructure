-- Auto-generated from wireguard-raspbian-zero.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install build tools",
      apt = Some {
        name = Some [
          "raspberrypi-kernel-headers"
        , "libmnl-dev"
        , "libelf-dev"
        , "build-essential"
        , "git"
      ]
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
      name = Some "Clone wireguard-linux-compat",
      git = Some {
        repo = "https://git.zx2c4.com/wireguard-linux-compat"
      , version = Some "master"
      , dest = "/root/wireguard-linux-compat"
      , force = None Bool
      , update = Some "{{ wireguard_update }}"
      , key_file = None Text
    },
      diff = Some False
    }
  , Task::{
      name = Some "Clone wireguard-tools",
      git = Some {
        repo = "https://git.zx2c4.com/wireguard-tools"
      , version = Some "master"
      , dest = "/root/wireguard-tools"
      , force = None Bool
      , update = Some "{{ wireguard_update }}"
      , key_file = None Text
    },
      diff = Some False
    }
  , Task::{
      name = Some "Compile and install wireguard-linux-compat",
      command = Some "make all install",
      args = Some {
        creates = Some "/root/wireguard-linux-compat/src/wireguard.ko"
      , chdir = Some "/root/wireguard-linux-compat/src"
      , executable = None Text
      , removes = None Text
    },
      register = Some "_r",
      failed_when = Some "_r.rc != 0"
    }
  , Task::{
      name = Some "Compile and install wireguard-tools",
      command = Some "make all install",
      args = Some {
        creates = Some "/usr/bin/wg"
      , chdir = Some "/root/wireguard-tools/src"
      , executable = None Text
      , removes = None Text
    },
      register = Some "_r",
      failed_when = Some "_r.rc != 0"
    }
  , Task::{
      name = Some "Create wireguard-reresolve-dns.sh symlink",
      file = Some {
        path = None Text
      , state = Some "link"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = Some "{{ wireguard_reresolve_script }}"
      , recurse = None Bool
      , src = Some "/root/wireguard-tools/contrib/reresolve-dns/reresolve-dns.sh"
    }
    }
  , Task::{
      name = Some "Making a note that wireguard is installed",
      set_fact = Some {
        certbot_nginx_conf = None Text
      , destjarfile = None Text
      , name = None Text
      , nebula_resolve_type = None Text
      , cacheable = Some True
      , nebula_ssh_public = None Text
      , quince_tomcat_dir = None Text
      , sshlogin_src_user = None Text
      , sshlogin_dst_user = None Text
      , _wg_is_installed = Some 1
    }
    }
]
