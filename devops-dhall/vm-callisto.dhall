-- Auto-generated from vm-callisto.yml

let Play =
    { Type =
        { hosts : Text
    , vars : Optional ({ callisto_ip : Text })
    , pre_tasks : Optional (List ({ name : Text, tags : List Text, include_role : Optional ({ name : Text, public : Bool }), vars : Optional ({ zfsdocker_name : Text, zfsdocker_size : Text }), lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, data : { path : Text, source : Text, type : Text, recursive : Text }, fluxcom : { path : Text, source : Text, type : Text }, fluxcom_eo : { path : Text, source : Text, type : Text }, stilt : { path : Text, source : Text, type : Text }, eurocom : { path : Text, source : Text, type : Text }, eurocom_web_root : { path : Text, source : Text, type : Text }, filedrop : { path : Text, source : Text, type : Text }, datademo : { path : Text, source : Text, type : Text }, radonmap : { path : Text, source : Text, type : Text } }, config : { `limits.memory` : Text, `security.nesting` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }), register : Optional Text }))
    , roles : List ({ role : Text, tags : Text, lxd_forward_name : Optional Text, lxd_forward_ip : Optional Text, eurocom_users : Optional Text, eurocom_web_root : Optional Text, eurocom_data_home : Optional Text, user_conf : Optional Text, docker_periodic_cleanup : Optional Bool, docker_prevent_upgrade : Optional Bool, filedrop_data_home : Optional Text, jupyter_admins : Optional Text, jupyter_user_volumes : Optional Text, jupyter_backup_enable : Optional Bool, sftp_user_dir : Optional Text, sftp_user_login : Optional Text, sftp_user_owner : Optional Text, sftp_user_password : Optional Text, sftp_user_hostdesc : Optional Text, bbclient_name : Optional Text, bbclient_remotes : Optional (List Text), bbclient_timer_content : Optional Text })
    , tasks : List ({ name : Text, tags : Text, include_role : Optional ({ name : Text, tasks_from : Text }), vars : Optional ({ nginxsite_name : Text, filedrop_domain : Optional Text, filedrop_host : Optional Text, jupyter_domain : Optional Text, jupyter_ip : Optional Text }), iptables_raw : Optional ({ name : Text, table : Text, rules : Text }) })
  }
    , default =
        { vars = None ({ callisto_ip : Text })
    , pre_tasks = None (List ({ name : Text, tags : List Text, include_role : Optional ({ name : Text, public : Bool }), vars : Optional ({ zfsdocker_name : Text, zfsdocker_size : Text }), lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, data : { path : Text, source : Text, type : Text, recursive : Text }, fluxcom : { path : Text, source : Text, type : Text }, fluxcom_eo : { path : Text, source : Text, type : Text }, stilt : { path : Text, source : Text, type : Text }, eurocom : { path : Text, source : Text, type : Text }, eurocom_web_root : { path : Text, source : Text, type : Text }, filedrop : { path : Text, source : Text, type : Text }, datademo : { path : Text, source : Text, type : Text }, radonmap : { path : Text, source : Text, type : Text } }, config : { `limits.memory` : Text, `security.nesting` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }), register : Optional Text }))
  }
    }

in  [
    Play::{
      hosts = "fsicos3",
      vars = Some { callisto_ip = "{{ _lxd.addresses.eth0 | first }}" },
      pre_tasks = Some [
        {
          name = "Cre ate storage for docker",
          tags = [ "lxd" ],
          include_role = Some { name = "icos.zfsdocker", public = True },
          vars = Some { zfsdocker_name = "callisto", zfsdocker_size = "50G" },
          lxd_container = None ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, data : { path : Text, source : Text, type : Text, recursive : Text }, fluxcom : { path : Text, source : Text, type : Text }, fluxcom_eo : { path : Text, source : Text, type : Text }, stilt : { path : Text, source : Text, type : Text }, eurocom : { path : Text, source : Text, type : Text }, eurocom_web_root : { path : Text, source : Text, type : Text }, filedrop : { path : Text, source : Text, type : Text }, datademo : { path : Text, source : Text, type : Text }, radonmap : { path : Text, source : Text, type : Text } }, config : { `limits.memory` : Text, `security.nesting` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }),
          register = None Text
        }
      , {
          name = "Create the callisto container",
          tags = [ "lxd", "forward" ],
          include_role = None ({ name : Text, public : Bool }),
          vars = None ({ zfsdocker_name : Text, zfsdocker_size : Text }),
          lxd_container = Some {
            name = "callisto"
          , state = "started"
          , profiles = [ "default", "ssh_root", "icosdata" ]
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
            , fluxcom = { path = "/ute/fluxcom", source = "/pool/fluxcom", type = "disk" }
            , fluxcom_eo = { path = "/ute/fluxcom_eo", source = "/nfs/fluxcom_eo", type = "disk" }
            , stilt = { path = "/ute/stilt", source = "/pool/ute/stilt", type = "disk" }
            , eurocom = { path = "/ute/eurocom", source = "/data/project/eurocom", type = "disk" }
            , eurocom_web_root = {
                path = "/ute/eurocom_web_root"
              , source = "/pool/ute/eurocom_web_root"
              , type = "disk"
            }
            , filedrop = { path = "/ute/filedrop", source = "/pool/ute/filedrop", type = "disk" }
            , datademo = { path = "/ute/dataDemo", source = "/pool/ute/dataDemo", type = "disk" }
            , radonmap = { path = "/ute/radon_map", source = "/pool/ute/radon_map", type = "disk" }
          }
          , config = { `limits.memory` = "256GB", `security.nesting` = "true" }
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
          lxd_forward_name = Some "callisto",
          lxd_forward_ip = Some "{{ callisto_ip }}",
          eurocom_users = None Text,
          eurocom_web_root = None Text,
          eurocom_data_home = None Text,
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          docker_prevent_upgrade = None Bool,
          filedrop_data_home = None Text,
          jupyter_admins = None Text,
          jupyter_user_volumes = None Text,
          jupyter_backup_enable = None Bool,
          sftp_user_dir = None Text,
          sftp_user_login = None Text,
          sftp_user_owner = None Text,
          sftp_user_password = None Text,
          sftp_user_hostdesc = None Text,
          bbclient_name = None Text,
          bbclient_remotes = None (List Text),
          bbclient_timer_content = None Text
        }
      , {
          role = "icos.eurocom",
          tags = "eurocom",
          lxd_forward_name = None Text,
          lxd_forward_ip = None Text,
          eurocom_users = Some "{{ vault_eurocom_users }}",
          eurocom_web_root = Some "/pool/ute/eurocom_web_root",
          eurocom_data_home = Some "/data/project/eurocom",
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          docker_prevent_upgrade = None Bool,
          filedrop_data_home = None Text,
          jupyter_admins = None Text,
          jupyter_user_volumes = None Text,
          jupyter_backup_enable = None Bool,
          sftp_user_dir = None Text,
          sftp_user_login = None Text,
          sftp_user_owner = None Text,
          sftp_user_password = None Text,
          sftp_user_hostdesc = None Text,
          bbclient_name = None Text,
          bbclient_remotes = None (List Text),
          bbclient_timer_content = None Text
        }
    ],
      tasks = [
        {
          name = "Proxy filedrop",
          tags = "filedrop",
          include_role = Some { name = "icos.filedrop", tasks_from = "proxy" },
          vars = Some {
            nginxsite_name = "filedrop"
          , filedrop_domain = Some "filedrop.icos-cp.eu"
          , filedrop_host = Some "callisto.lxd"
          , jupyter_domain = None Text
          , jupyter_ip = None Text
        },
          iptables_raw = None ({ name : Text, table : Text, rules : Text })
        }
      , {
          name = "Proxy jupyter",
          tags = "jupyter",
          include_role = Some { name = "icos.jupyter", tasks_from = "proxy" },
          vars = Some {
            nginxsite_name = "callisto"
          , filedrop_domain = None Text
          , filedrop_host = None Text
          , jupyter_domain = Some "callisto.icos-cp.eu"
          , jupyter_ip = Some "callisto.lxd"
        },
          iptables_raw = None ({ name : Text, table : Text, rules : Text })
        }
    ]
    }
  , Play::{
      hosts = "callisto",
      roles = [
        {
          role = "icos.lxd_guest",
          tags = "guest",
          lxd_forward_name = None Text,
          lxd_forward_ip = None Text,
          eurocom_users = None Text,
          eurocom_web_root = None Text,
          eurocom_data_home = None Text,
          user_conf = Some "{{ vault_callisto_user_conf }}",
          docker_periodic_cleanup = None Bool,
          docker_prevent_upgrade = None Bool,
          filedrop_data_home = None Text,
          jupyter_admins = None Text,
          jupyter_user_volumes = None Text,
          jupyter_backup_enable = None Bool,
          sftp_user_dir = None Text,
          sftp_user_login = None Text,
          sftp_user_owner = None Text,
          sftp_user_password = None Text,
          sftp_user_hostdesc = None Text,
          bbclient_name = None Text,
          bbclient_remotes = None (List Text),
          bbclient_timer_content = None Text
        }
      , {
          role = "icos.docker",
          tags = "docker",
          lxd_forward_name = None Text,
          lxd_forward_ip = None Text,
          eurocom_users = None Text,
          eurocom_web_root = None Text,
          eurocom_data_home = None Text,
          user_conf = None Text,
          docker_periodic_cleanup = Some True,
          docker_prevent_upgrade = Some True,
          filedrop_data_home = None Text,
          jupyter_admins = None Text,
          jupyter_user_volumes = None Text,
          jupyter_backup_enable = None Bool,
          sftp_user_dir = None Text,
          sftp_user_login = None Text,
          sftp_user_owner = None Text,
          sftp_user_password = None Text,
          sftp_user_hostdesc = None Text,
          bbclient_name = None Text,
          bbclient_remotes = None (List Text),
          bbclient_timer_content = None Text
        }
      , {
          role = "icos.filedrop",
          tags = "filedrop",
          lxd_forward_name = None Text,
          lxd_forward_ip = None Text,
          eurocom_users = None Text,
          eurocom_web_root = None Text,
          eurocom_data_home = None Text,
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          docker_prevent_upgrade = None Bool,
          filedrop_data_home = Some "/ute/filedrop",
          jupyter_admins = None Text,
          jupyter_user_volumes = None Text,
          jupyter_backup_enable = None Bool,
          sftp_user_dir = None Text,
          sftp_user_login = None Text,
          sftp_user_owner = None Text,
          sftp_user_password = None Text,
          sftp_user_hostdesc = None Text,
          bbclient_name = None Text,
          bbclient_remotes = None (List Text),
          bbclient_timer_content = None Text
        }
      , {
          role = "icos.jupyter",
          tags = "jupyter",
          lxd_forward_name = None Text,
          lxd_forward_ip = None Text,
          eurocom_users = None Text,
          eurocom_web_root = None Text,
          eurocom_data_home = None Text,
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          docker_prevent_upgrade = None Bool,
          filedrop_data_home = None Text,
          jupyter_admins = Some "{{ vault_callisto_admins }}",
          jupyter_user_volumes = Some "{{ vault_callisto_user_volumes }}",
          jupyter_backup_enable = Some False,
          sftp_user_dir = None Text,
          sftp_user_login = None Text,
          sftp_user_owner = None Text,
          sftp_user_password = None Text,
          sftp_user_hostdesc = None Text,
          bbclient_name = None Text,
          bbclient_remotes = None (List Text),
          bbclient_timer_content = None Text
        }
      , {
          role = "icos.sftp_user",
          tags = "sftp",
          lxd_forward_name = None Text,
          lxd_forward_ip = None Text,
          eurocom_users = None Text,
          eurocom_web_root = None Text,
          eurocom_data_home = None Text,
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          docker_prevent_upgrade = None Bool,
          filedrop_data_home = None Text,
          jupyter_admins = None Text,
          jupyter_user_volumes = None Text,
          jupyter_backup_enable = None Bool,
          sftp_user_dir = Some "/ute/sftp_home/data",
          sftp_user_login = Some "sftp",
          sftp_user_owner = Some "ute",
          sftp_user_password = Some "{{ vault_callisto_sftp_password }}",
          sftp_user_hostdesc = None Text,
          bbclient_name = None Text,
          bbclient_remotes = None (List Text),
          bbclient_timer_content = None Text
        }
      , {
          role = "icos.sftp_user",
          tags = "sftp",
          lxd_forward_name = None Text,
          lxd_forward_ip = None Text,
          eurocom_users = None Text,
          eurocom_web_root = None Text,
          eurocom_data_home = None Text,
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          docker_prevent_upgrade = None Bool,
          filedrop_data_home = None Text,
          jupyter_admins = None Text,
          jupyter_user_volumes = None Text,
          jupyter_backup_enable = None Bool,
          sftp_user_dir = Some "/ute/fluxcom/upload",
          sftp_user_login = Some "{{ vault_callisto_sftp_fluxcom_upload_username }}",
          sftp_user_owner = None Text,
          sftp_user_password = Some "{{ vault_callisto_sftp_fluxcom_upload_password }}",
          sftp_user_hostdesc = Some "fluxcom-upload",
          bbclient_name = None Text,
          bbclient_remotes = None (List Text),
          bbclient_timer_content = None Text
        }
      , {
          role = "icos.bbclient2",
          tags = "bbclient_ute",
          lxd_forward_name = None Text,
          lxd_forward_ip = None Text,
          eurocom_users = None Text,
          eurocom_web_root = None Text,
          eurocom_data_home = None Text,
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          docker_prevent_upgrade = None Bool,
          filedrop_data_home = None Text,
          jupyter_admins = None Text,
          jupyter_user_volumes = None Text,
          jupyter_backup_enable = None Bool,
          sftp_user_dir = None Text,
          sftp_user_login = None Text,
          sftp_user_owner = None Text,
          sftp_user_password = None Text,
          sftp_user_hostdesc = None Text,
          bbclient_name = Some "callisto_home_ute",
          bbclient_remotes = Some [ "fsicos2", "icos1" ],
          bbclient_timer_content = Some ''
          #!/bin/bash
          set -eu
          echo "Creating"
          {{ bbclient_all }} create --stats --verbose "::{now}" /home/ute

          echo "Pruning"
          {{ bbclient_all }} prune --stats --keep-within=100d --keep-weekly=-1

          echo "Compacting"
          {{ bbclient_all }} compact --verbose

        ''
        }
      , {
          role = "icos.bbclient2",
          tags = "bbclient_radon",
          lxd_forward_name = None Text,
          lxd_forward_ip = None Text,
          eurocom_users = None Text,
          eurocom_web_root = None Text,
          eurocom_data_home = None Text,
          user_conf = None Text,
          docker_periodic_cleanup = None Bool,
          docker_prevent_upgrade = None Bool,
          filedrop_data_home = None Text,
          jupyter_admins = None Text,
          jupyter_user_volumes = None Text,
          jupyter_backup_enable = None Bool,
          sftp_user_dir = None Text,
          sftp_user_login = None Text,
          sftp_user_owner = None Text,
          sftp_user_password = None Text,
          sftp_user_hostdesc = None Text,
          bbclient_name = Some "radon_map",
          bbclient_remotes = Some [ "fsicos2", "icos1" ],
          bbclient_timer_content = Some ''
          #!/bin/bash
          set -eu
          echo "Creating"
          {{ bbclient_all }} create --stats --verbose "::{now}" /data/radon_map

          echo "Pruning"
          {{ bbclient_all }} prune --stats --keep-within=100d --keep-weekly=-1

          echo "Compacting"
          {{ bbclient_all }} compact --verbose

        ''
        }
    ],
      tasks = [
        {
          name = "Port forward for filedrop",
          tags = "iptables",
          include_role = None ({ name : Text, tasks_from : Text }),
          vars = None ({ nginxsite_name : Text, filedrop_domain : Optional Text, filedrop_host : Optional Text, jupyter_domain : Optional Text, jupyter_ip : Optional Text }),
          iptables_raw = Some {
            name = "forward_filedrop"
          , table = "nat"
          , rules = "-A PREROUTING -p tcp --dport {{ filedrop_port }} -j DNAT --to-destination 127.0.0.1:{{ filedrop_port }}"
        }
        }
    ]
    }
]
