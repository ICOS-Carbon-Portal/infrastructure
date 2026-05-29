-- Auto-generated from ../devops/vm-fsicos3-jupyter.yml

let Play =
    { Type =
        { hosts : Text
    , vars : Optional ({ jupyter_ip : Text, jupyter_domains : List Text })
    , pre_tasks : Optional (List ({ name : Text, tags : Text, zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : { refquota : Text } }), file : Optional ({ name : Text, state : Text, owner : Text, group : Text }), loop : Optional (List Text) }))
    , roles : List ({ role : Text, tags : Text, lxd_vm_name : Optional Text, lxd_vm_ubuntu_version : Optional Text, lxd_vm_docker : Optional Bool, lxd_vm_docker_size : Optional Text, lxd_vm_root_pool : Optional Text, lxd_vm_root_size : Optional Text, lxd_vm_config : Optional ({ `limits.memory` : Text }), lxd_vm_profiles : Optional (List Text), lxd_vm_devices : Optional ({ ctehires : { path : Text, source : Text, type : Text }, data : { path : Text, source : Text, type : Text, recursive : Text }, home : { path : Text, source : Text, type : Text }, jupyterproject : { path : Text, source : Text, type : Text, recursive : Text } }), certbot_name : Optional Text, certbot_domains : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, jupyter_domain : Optional Text, jupyter_cert_name : Optional Text, jupyter_port : Optional Natural, sshlogin_dst : Optional Text, sshlogin_src_user : Optional Text, sshlogin_dst_user : Optional Text, sshlogin_src_dst_name : Optional Text, jupyter_hub_config : Optional ({ admin_users : Text, mem_limit : Text, cpu_limit : Natural }), jupyter_admins : Optional Text, jupyter_jusers_enable : Optional Bool, bbclient_remotes : Optional (List Text), bbclient_name : Optional Text, bbclient_timer_content : Optional Text })
    , handlers : Optional (List ({ name : Text, systemd : { name : Text, state : Text } }))
    , tasks : Optional (List ({ name : Text, tags : Text, user : Optional ({ name : Text, create_home : Bool, home : Text, shell : Text, password : Text }), copy : Optional ({ dest : Text, content : Text }), notify : Optional Text, replace : Optional ({ path : Text, regexp : Text, replace : Text }) }))
  }
    , default =
        { vars = None ({ jupyter_ip : Text, jupyter_domains : List Text })
    , pre_tasks = None (List ({ name : Text, tags : Text, zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : { refquota : Text } }), file : Optional ({ name : Text, state : Text, owner : Text, group : Text }), loop : Optional (List Text) }))
    , handlers = None (List ({ name : Text, systemd : { name : Text, state : Text } }))
    , tasks = None (List ({ name : Text, tags : Text, user : Optional ({ name : Text, create_home : Bool, home : Text, shell : Text, password : Text }), copy : Optional ({ dest : Text, content : Text }), notify : Optional Text, replace : Optional ({ path : Text, regexp : Text, replace : Text }) }))
  }
    }

in  [
    Play::{
      hosts = "fsicos3",
      vars = Some {
        jupyter_ip = "{{ _lxd.addresses.eth0 | first }}"
      , jupyter_domains = [ "jupyter.icos-cp.eu" ]
    },
      pre_tasks = Some (let Entry =
        { Type =
            { name : Text
        , tags : Text
        , zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : { refquota : Text } })
        , file : Optional ({ name : Text, state : Text, owner : Text, group : Text })
        , loop : Optional (List Text)
      }
        , default =
            { zfs = None ({ name : Text, state : Text, extra_zfs_properties : { refquota : Text } })
        , file = None ({ name : Text, state : Text, owner : Text, group : Text })
        , loop = None (List Text)
      }
        }

    in  [
        Entry::{
          name = "Create zfs filesystem for jupyter home directories",
          tags = "zfs",
          zfs = Some {
            name = "pool/jupyter"
          , state = "present"
          , extra_zfs_properties = { refquota = "5T" }
        }
        }
      , Entry::{
          name = "Create jupyter directories for home and project",
          tags = "zfs",
          file = Some {
            name = "/pool/jupyter/{{ item }}"
          , state = "directory"
          , owner = "1000000"
          , group = "1000000"
        },
          loop = Some [ "home", "project" ]
        }
    ]),
      roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_ubuntu_version : Optional Text
        , lxd_vm_docker : Optional Bool
        , lxd_vm_docker_size : Optional Text
        , lxd_vm_root_pool : Optional Text
        , lxd_vm_root_size : Optional Text
        , lxd_vm_config : Optional ({ `limits.memory` : Text })
        , lxd_vm_profiles : Optional (List Text)
        , lxd_vm_devices : Optional ({ ctehires : { path : Text, source : Text, type : Text }, data : { path : Text, source : Text, type : Text, recursive : Text }, home : { path : Text, source : Text, type : Text }, jupyterproject : { path : Text, source : Text, type : Text, recursive : Text } })
        , certbot_name : Optional Text
        , certbot_domains : Optional Text
        , nginxsite_name : Optional Text
        , nginxsite_file : Optional Text
        , jupyter_domain : Optional Text
        , jupyter_cert_name : Optional Text
        , jupyter_port : Optional Natural
        , sshlogin_dst : Optional Text
        , sshlogin_src_user : Optional Text
        , sshlogin_dst_user : Optional Text
        , sshlogin_src_dst_name : Optional Text
        , jupyter_hub_config : Optional ({ admin_users : Text, mem_limit : Text, cpu_limit : Natural })
        , jupyter_admins : Optional Text
        , jupyter_jusers_enable : Optional Bool
        , bbclient_remotes : Optional (List Text)
        , bbclient_name : Optional Text
        , bbclient_timer_content : Optional Text
      }
        , default =
            { lxd_vm_name = None Text
        , lxd_vm_ubuntu_version = None Text
        , lxd_vm_docker = None Bool
        , lxd_vm_docker_size = None Text
        , lxd_vm_root_pool = None Text
        , lxd_vm_root_size = None Text
        , lxd_vm_config = None ({ `limits.memory` : Text })
        , lxd_vm_profiles = None (List Text)
        , lxd_vm_devices = None ({ ctehires : { path : Text, source : Text, type : Text }, data : { path : Text, source : Text, type : Text, recursive : Text }, home : { path : Text, source : Text, type : Text }, jupyterproject : { path : Text, source : Text, type : Text, recursive : Text } })
        , certbot_name = None Text
        , certbot_domains = None Text
        , nginxsite_name = None Text
        , nginxsite_file = None Text
        , jupyter_domain = None Text
        , jupyter_cert_name = None Text
        , jupyter_port = None Natural
        , sshlogin_dst = None Text
        , sshlogin_src_user = None Text
        , sshlogin_dst_user = None Text
        , sshlogin_src_dst_name = None Text
        , jupyter_hub_config = None ({ admin_users : Text, mem_limit : Text, cpu_limit : Natural })
        , jupyter_admins = None Text
        , jupyter_jusers_enable = None Bool
        , bbclient_remotes = None (List Text)
        , bbclient_name = None Text
        , bbclient_timer_content = None Text
      }
        }

    in  [
        Role::{
          role = "icos.lxd_vm",
          tags = "lxd",
          lxd_vm_name = Some "jupyter",
          lxd_vm_ubuntu_version = Some "22.04",
          lxd_vm_docker = Some True,
          lxd_vm_docker_size = Some "500G",
          lxd_vm_root_pool = Some "default",
          lxd_vm_root_size = Some "50GB",
          lxd_vm_config = Some { `limits.memory` = "550GB" },
          lxd_vm_profiles = Some [ "icosdata" ],
          lxd_vm_devices = Some {
            ctehires = { path = "/ctehires", source = "/pool/ctehires", type = "disk" }
          , data = {
              path = "/data"
            , source = "/data"
            , type = "disk"
            , recursive = "yes"
          }
          , home = { path = "/home", source = "/pool/jupyter/home", type = "disk" }
          , jupyterproject = {
              path = "/project"
            , source = "/pool/jupyter/project"
            , type = "disk"
            , recursive = "yes"
          }
        }
        }
      , Role::{
          role = "icos.certbot2",
          tags = "cert",
          certbot_name = Some "jupyter",
          certbot_domains = Some "{{ jupyter_domains }}"
        }
      , Role::{
          role = "icos.nginxsite",
          tags = "nginx",
          nginxsite_name = Some "jupyter",
          nginxsite_file = Some "files/jupyter.conf",
          jupyter_domain = Some "{{ jupyter_domains | first }}",
          jupyter_cert_name = Some "jupyter",
          jupyter_port = Some 8000
        }
    ]
    }
  , Play::{
      hosts = "jupyter",
      roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , lxd_vm_name : Optional Text
        , lxd_vm_ubuntu_version : Optional Text
        , lxd_vm_docker : Optional Bool
        , lxd_vm_docker_size : Optional Text
        , lxd_vm_root_pool : Optional Text
        , lxd_vm_root_size : Optional Text
        , lxd_vm_config : Optional ({ `limits.memory` : Text })
        , lxd_vm_profiles : Optional (List Text)
        , lxd_vm_devices : Optional ({ ctehires : { path : Text, source : Text, type : Text }, data : { path : Text, source : Text, type : Text, recursive : Text }, home : { path : Text, source : Text, type : Text }, jupyterproject : { path : Text, source : Text, type : Text, recursive : Text } })
        , certbot_name : Optional Text
        , certbot_domains : Optional Text
        , nginxsite_name : Optional Text
        , nginxsite_file : Optional Text
        , jupyter_domain : Optional Text
        , jupyter_cert_name : Optional Text
        , jupyter_port : Optional Natural
        , sshlogin_dst : Optional Text
        , sshlogin_src_user : Optional Text
        , sshlogin_dst_user : Optional Text
        , sshlogin_src_dst_name : Optional Text
        , jupyter_hub_config : Optional ({ admin_users : Text, mem_limit : Text, cpu_limit : Natural })
        , jupyter_admins : Optional Text
        , jupyter_jusers_enable : Optional Bool
        , bbclient_remotes : Optional (List Text)
        , bbclient_name : Optional Text
        , bbclient_timer_content : Optional Text
      }
        , default =
            { lxd_vm_name = None Text
        , lxd_vm_ubuntu_version = None Text
        , lxd_vm_docker = None Bool
        , lxd_vm_docker_size = None Text
        , lxd_vm_root_pool = None Text
        , lxd_vm_root_size = None Text
        , lxd_vm_config = None ({ `limits.memory` : Text })
        , lxd_vm_profiles = None (List Text)
        , lxd_vm_devices = None ({ ctehires : { path : Text, source : Text, type : Text }, data : { path : Text, source : Text, type : Text, recursive : Text }, home : { path : Text, source : Text, type : Text }, jupyterproject : { path : Text, source : Text, type : Text, recursive : Text } })
        , certbot_name = None Text
        , certbot_domains = None Text
        , nginxsite_name = None Text
        , nginxsite_file = None Text
        , jupyter_domain = None Text
        , jupyter_cert_name = None Text
        , jupyter_port = None Natural
        , sshlogin_dst = None Text
        , sshlogin_src_user = None Text
        , sshlogin_dst_user = None Text
        , sshlogin_src_dst_name = None Text
        , jupyter_hub_config = None ({ admin_users : Text, mem_limit : Text, cpu_limit : Natural })
        , jupyter_admins = None Text
        , jupyter_jusers_enable = None Bool
        , bbclient_remotes = None (List Text)
        , bbclient_name = None Text
        , bbclient_timer_content = None Text
      }
        }

    in  [
        Role::{ role = "icos.lxd_guest", tags = "guest" }
      , Role::{ role = "icos.docker2", tags = "docker" }
      , Role::{
          role = "icos.sshlogin",
          tags = "sshlogin_exploredata",
          sshlogin_dst = Some "exploredata",
          sshlogin_src_user = Some "root",
          sshlogin_dst_user = Some "root",
          sshlogin_src_dst_name = Some "exploredata"
        }
      , Role::{
          role = "icos.jupyter",
          tags = "jupyter",
          jupyter_hub_config = Some { admin_users = "{{ vault_jupyter_admins }}", mem_limit = "100G", cpu_limit = 40 },
          jupyter_jusers_enable = Some True
        }
      , Role::{
          role = "icos.bbclient2",
          tags = "bbclient",
          bbclient_remotes = Some [ "fsicos2", "icos1" ],
          bbclient_name = Some "jupyter",
          bbclient_timer_content = Some ''
          #!/bin/bash
          set -xeu

          # If the repos get moved to another disk - maybe because of storage
          # running out - we don't want the backup to fail.
          export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes

          {{ bbclient_all }} create --verbose --stats -x "::{now}" /home /project /root/jusers.yml
          {{ bbclient_all }} prune --stats --list --keep-daily=30 --keep-weekly=150

          # since borg 1.2, a separate compaction is needed
          {{ bbclient_all }} compact --verbose

        ''
        }
    ],
      handlers = Some [
        { name = "reload sshd", systemd = { name = "sshd", state = "reloaded" } }
    ],
      tasks = Some (let Task =
        { Type =
            { name : Text
        , tags : Text
        , user : Optional ({ name : Text, create_home : Bool, home : Text, shell : Text, password : Text })
        , copy : Optional ({ dest : Text, content : Text })
        , notify : Optional Text
        , replace : Optional ({ path : Text, regexp : Text, replace : Text })
      }
        , default =
            { user = None ({ name : Text, create_home : Bool, home : Text, shell : Text, password : Text })
        , copy = None ({ dest : Text, content : Text })
        , notify = None Text
        , replace = None ({ path : Text, regexp : Text, replace : Text })
      }
        }

    in  [
        Task::{
          name = "Create project user",
          tags = "project",
          user = Some {
            name = "project"
          , create_home = True
          , home = "/home/project"
          , shell = "/usr/bin/bash"
          , password = "*"
        }
        }
      , Task::{
          name = "Deny ssh login to most users",
          tags = "ssh",
          copy = Some {
            dest = "/etc/ssh/sshd_config.d/jupyter_allow_users.conf"
          , content = ''
            AllowUsers project {{ vault_jupyter_ssh_users | join(" ") }}

          ''
        },
          notify = Some "reload sshd"
        }
      , Task::{
          name = "Change adduser.conf",
          tags = "adduser",
          replace = Some {
            path = "/etc/adduser.conf"
          , regexp = "^(FIRST_UID|FIRST_GID)=\\d+"
          , replace = "\\1=2500"
        }
        }
    ])
    }
]
