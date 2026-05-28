-- Auto-generated from vm-ganymede.yml

let Play =
    { Type =
        { hosts : Text
    , vars : Optional ({ jupyter_ip : Text, jupyter_domains : List Text, ganymede_domains : List Text })
    , pre_tasks : Optional (List ({ include_role : Optional ({ name : Text, public : Bool }), tags : List Text, vars : Optional ({ zfsdocker_name : Text, zfsdocker_size : Text }), name : Optional Text, lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, data : { path : Text, source : Text, type : Text, recursive : Text } }, config : { `limits.memory` : Text, `security.nesting` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }), register : Optional Text }))
    , roles : List ({ role : Text, tags : Text, lxd_forward_ip : Optional Text, lxd_forward_name : Optional Text, certbot_name : Optional Text, certbot_domains : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, jupyter_domain : Optional Text, jupyter_cert_name : Optional Text, jupyter_port : Optional Natural, nginxforward_name : Optional Text, nginxforward_host : Optional Text, nginxforward_port : Optional Natural, nginxforward_cert : Optional Text, nginxforward_domains : Optional (List Text), user_conf : Optional Text, docker_periodic_cleanup : Optional Bool, jupyter_admins : Optional Text, jupyter_backup_enable : Optional Bool, jbuild_users : Optional Text, jbuild_registry_pass : Optional Text, jbuild_edctl_host : Optional Text, jbuild_edctl_host_name : Optional Text, jbuild_edctl_host_port : Optional Natural, jbuild_rsync_host : Optional Text, jbuild_rsync_host_port : Optional Natural, jbuild_rsync_host_name : Optional Text, jbuild_jyctl_host : Optional Text, jbuild_jyctl_host_port : Optional Natural, jbuild_jyctl_host_name : Optional Text })
    , handlers : Optional (List ({ name : Text, systemd : { name : Text, state : Text } }))
    , tasks : Optional (List ({ tags : Text, include_role : { name : Text, apply : { tags : Text } }, vars : { sshlogin_dst : Text, sshlogin_src_user : Text, sshlogin_dst_user : Text, sshlogin_src_dst_host : Text, sshlogin_src_dst_port : Text }, loop : Text, loop_control : { loop_var : Text } }))
  }
    , default =
        { vars = None ({ jupyter_ip : Text, jupyter_domains : List Text, ganymede_domains : List Text })
    , pre_tasks = None (List ({ include_role : Optional ({ name : Text, public : Bool }), tags : List Text, vars : Optional ({ zfsdocker_name : Text, zfsdocker_size : Text }), name : Optional Text, lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, data : { path : Text, source : Text, type : Text, recursive : Text } }, config : { `limits.memory` : Text, `security.nesting` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }), register : Optional Text }))
    , handlers = None (List ({ name : Text, systemd : { name : Text, state : Text } }))
    , tasks = None (List ({ tags : Text, include_role : { name : Text, apply : { tags : Text } }, vars : { sshlogin_dst : Text, sshlogin_src_user : Text, sshlogin_dst_user : Text, sshlogin_src_dst_host : Text, sshlogin_src_dst_port : Text }, loop : Text, loop_control : { loop_var : Text } }))
  }
    }

in  [
    Play::{
      hosts = "fsicos3",
      vars = Some {
        jupyter_ip = "{{ _lxd.addresses.eth0 | first }}"
      , jupyter_domains = [ "ganymede.icos-cp.eu" ]
      , ganymede_domains = [ "future.ganymede.icos-cp.eu" ]
    },
      pre_tasks = Some [
        {
          include_role = Some { name = "icos.zfsdocker", public = True },
          tags = [ "zfs", "lxd" ],
          vars = Some { zfsdocker_name = "ganymede", zfsdocker_size = "100G" },
          name = None Text,
          lxd_container = None ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, data : { path : Text, source : Text, type : Text, recursive : Text } }, config : { `limits.memory` : Text, `security.nesting` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }),
          register = None Text
        }
      , {
          include_role = None ({ name : Text, public : Bool }),
          tags = [ "lxd", "forward", "nginx", "icosdata" ],
          vars = None ({ zfsdocker_name : Text, zfsdocker_size : Text }),
          name = Some "Create the ganymede container",
          lxd_container = Some {
            name = "ganymede"
          , state = "started"
          , profiles = [ "default", "ssh_root" ]
          , source = {
              type = "image"
            , mode = "pull"
            , server = "https://cloud-images.ubuntu.com/releases"
            , protocol = "simplestreams"
            , alias = "20.04"
          }
          , devices = {
              root = {
                path = "/"
              , pool = "default"
              , type = "disk"
              , size = "500GB"
            }
            , docker = {
                path = "/var/lib/docker"
              , source = "{{ zfsdocker_zvol }}"
              , type = "disk"
              , `raw.mount.options` = "user_subvol_rm_allowed"
            }
            , data = {
                path = "/data"
              , source = "/data"
              , type = "disk"
              , recursive = "yes"
            }
          }
          , config = { `limits.memory` = "100GB", `security.nesting` = "true" }
          , wait_for_ipv4_addresses = True
          , wait_for_ipv4_interfaces = "eth0"
          , timeout = 60
        },
          register = Some "_lxd"
        }
    ],
      roles = [
        {
          role = "icos.lxd_forward",
          tags = "forward",
          lxd_forward_ip = Some "{{ jupyter_ip }}",
          lxd_forward_name = Some "ganymede",
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          jupyter_domain = None Text,
          jupyter_cert_name = None Text,
          jupyter_port = None Natural,
          nginxforward_name = None Text,
          nginxforward_host = None Text,
          nginxforward_port = None Natural,
          nginxforward_cert = None Text,
          nginxforward_domains = None (List Text),
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          jupyter_admins = None Text,
          jupyter_backup_enable = None Bool,
          jbuild_users = None Text,
          jbuild_registry_pass = None Text,
          jbuild_edctl_host = None Text,
          jbuild_edctl_host_name = None Text,
          jbuild_edctl_host_port = None Natural,
          jbuild_rsync_host = None Text,
          jbuild_rsync_host_port = None Natural,
          jbuild_rsync_host_name = None Text,
          jbuild_jyctl_host = None Text,
          jbuild_jyctl_host_port = None Natural,
          jbuild_jyctl_host_name = None Text
        }
      , {
          role = "icos.certbot2",
          tags = "cert",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          certbot_name = Some "ganymede",
          certbot_domains = Some "{{ jupyter_domains + ganymede_domains }}",
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          jupyter_domain = None Text,
          jupyter_cert_name = None Text,
          jupyter_port = None Natural,
          nginxforward_name = None Text,
          nginxforward_host = None Text,
          nginxforward_port = None Natural,
          nginxforward_cert = None Text,
          nginxforward_domains = None (List Text),
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          jupyter_admins = None Text,
          jupyter_backup_enable = None Bool,
          jbuild_users = None Text,
          jbuild_registry_pass = None Text,
          jbuild_edctl_host = None Text,
          jbuild_edctl_host_name = None Text,
          jbuild_edctl_host_port = None Natural,
          jbuild_rsync_host = None Text,
          jbuild_rsync_host_port = None Natural,
          jbuild_rsync_host_name = None Text,
          jbuild_jyctl_host = None Text,
          jbuild_jyctl_host_port = None Natural,
          jbuild_jyctl_host_name = None Text
        }
      , {
          role = "icos.nginxsite",
          tags = "nginx",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = Some "ganymede",
          nginxsite_file = Some "files/jupyter.conf",
          jupyter_domain = Some "{{ jupyter_domains | first }}",
          jupyter_cert_name = Some "ganymede",
          jupyter_port = Some 8000,
          nginxforward_name = None Text,
          nginxforward_host = None Text,
          nginxforward_port = None Natural,
          nginxforward_cert = None Text,
          nginxforward_domains = None (List Text),
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          jupyter_admins = None Text,
          jupyter_backup_enable = None Bool,
          jbuild_users = None Text,
          jbuild_registry_pass = None Text,
          jbuild_edctl_host = None Text,
          jbuild_edctl_host_name = None Text,
          jbuild_edctl_host_port = None Natural,
          jbuild_rsync_host = None Text,
          jbuild_rsync_host_port = None Natural,
          jbuild_rsync_host_name = None Text,
          jbuild_jyctl_host = None Text,
          jbuild_jyctl_host_port = None Natural,
          jbuild_jyctl_host_name = None Text
        }
      , {
          role = "icos.nginxforward",
          tags = "future",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          jupyter_domain = None Text,
          jupyter_cert_name = None Text,
          jupyter_port = None Natural,
          nginxforward_name = Some "future_ganymede",
          nginxforward_host = Some "ganymede.lxd",
          nginxforward_port = Some 8081,
          nginxforward_cert = Some "ganymede",
          nginxforward_domains = Some [ "future.ganymede.icos-cp.eu" ],
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          jupyter_admins = None Text,
          jupyter_backup_enable = None Bool,
          jbuild_users = None Text,
          jbuild_registry_pass = None Text,
          jbuild_edctl_host = None Text,
          jbuild_edctl_host_name = None Text,
          jbuild_edctl_host_port = None Natural,
          jbuild_rsync_host = None Text,
          jbuild_rsync_host_port = None Natural,
          jbuild_rsync_host_name = None Text,
          jbuild_jyctl_host = None Text,
          jbuild_jyctl_host_port = None Natural,
          jbuild_jyctl_host_name = None Text
        }
    ]
    }
  , Play::{
      hosts = "ganymede",
      roles = [
        {
          role = "icos.lxd_guest",
          tags = "guest",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          jupyter_domain = None Text,
          jupyter_cert_name = None Text,
          jupyter_port = None Natural,
          nginxforward_name = None Text,
          nginxforward_host = None Text,
          nginxforward_port = None Natural,
          nginxforward_cert = None Text,
          nginxforward_domains = None (List Text),
          user_conf = Some "{{ vault_ganymede_user_conf }}",
          docker_periodic_cleanup = None Bool,
          jupyter_admins = None Text,
          jupyter_backup_enable = None Bool,
          jbuild_users = None Text,
          jbuild_registry_pass = None Text,
          jbuild_edctl_host = None Text,
          jbuild_edctl_host_name = None Text,
          jbuild_edctl_host_port = None Natural,
          jbuild_rsync_host = None Text,
          jbuild_rsync_host_port = None Natural,
          jbuild_rsync_host_name = None Text,
          jbuild_jyctl_host = None Text,
          jbuild_jyctl_host_port = None Natural,
          jbuild_jyctl_host_name = None Text
        }
      , {
          role = "icos.docker",
          tags = "docker",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          jupyter_domain = None Text,
          jupyter_cert_name = None Text,
          jupyter_port = None Natural,
          nginxforward_name = None Text,
          nginxforward_host = None Text,
          nginxforward_port = None Natural,
          nginxforward_cert = None Text,
          nginxforward_domains = None (List Text),
          user_conf = None Text,
          docker_periodic_cleanup = Some True,
          jupyter_admins = None Text,
          jupyter_backup_enable = None Bool,
          jbuild_users = None Text,
          jbuild_registry_pass = None Text,
          jbuild_edctl_host = None Text,
          jbuild_edctl_host_name = None Text,
          jbuild_edctl_host_port = None Natural,
          jbuild_rsync_host = None Text,
          jbuild_rsync_host_port = None Natural,
          jbuild_rsync_host_name = None Text,
          jbuild_jyctl_host = None Text,
          jbuild_jyctl_host_port = None Natural,
          jbuild_jyctl_host_name = None Text
        }
      , {
          role = "icos.jupyter",
          tags = "jupyter",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          jupyter_domain = None Text,
          jupyter_cert_name = None Text,
          jupyter_port = None Natural,
          nginxforward_name = None Text,
          nginxforward_host = None Text,
          nginxforward_port = None Natural,
          nginxforward_cert = None Text,
          nginxforward_domains = None (List Text),
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          jupyter_admins = Some "{{ vault_ganymede_jupyter_admins }}",
          jupyter_backup_enable = Some False,
          jbuild_users = None Text,
          jbuild_registry_pass = None Text,
          jbuild_edctl_host = None Text,
          jbuild_edctl_host_name = None Text,
          jbuild_edctl_host_port = None Natural,
          jbuild_rsync_host = None Text,
          jbuild_rsync_host_port = None Natural,
          jbuild_rsync_host_name = None Text,
          jbuild_jyctl_host = None Text,
          jbuild_jyctl_host_port = None Natural,
          jbuild_jyctl_host_name = None Text
        }
      , {
          role = "icos.jbuild",
          tags = "jbuild",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          jupyter_domain = None Text,
          jupyter_cert_name = None Text,
          jupyter_port = None Natural,
          nginxforward_name = None Text,
          nginxforward_host = None Text,
          nginxforward_port = None Natural,
          nginxforward_cert = None Text,
          nginxforward_domains = None (List Text),
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          jupyter_admins = None Text,
          jupyter_backup_enable = None Bool,
          jbuild_users = Some "{{ vault_ganymede_jbuild_users }}",
          jbuild_registry_pass = Some "{{ vault_registry_pass }}",
          jbuild_edctl_host = Some "exploredata",
          jbuild_edctl_host_name = Some "exploredata.lxd",
          jbuild_edctl_host_port = Some 22,
          jbuild_rsync_host = Some "jupyter",
          jbuild_rsync_host_port = Some 22,
          jbuild_rsync_host_name = Some "jupyter.lxd",
          jbuild_jyctl_host = Some "jupyter",
          jbuild_jyctl_host_port = Some 22,
          jbuild_jyctl_host_name = Some "jupyter.lxd"
        }
    ],
      handlers = Some [
        { name = "reload sshd", systemd = { name = "sshd", state = "reloaded" } }
    ],
      tasks = Some [
        {
          tags = "sshlogin"
        , include_role = { name = "icos.sshlogin", apply = { tags = "sshlogin" } }
        , vars = {
            sshlogin_dst = "{{ login.dst }}"
          , sshlogin_src_user = "{{ login.src_user }}"
          , sshlogin_dst_user = "{{ login.dst_user }}"
          , sshlogin_src_dst_host = "{{ login.dst_host }}"
          , sshlogin_src_dst_port = "{{ login.dst_port }}"
        }
        , loop = "{{ vault_ganymede_sshlogins }}"
        , loop_control = { loop_var = "login" }
      }
    ]
    }
]
