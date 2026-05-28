-- Auto-generated from vm-fsicos3-flexpart.yml

let Play =
    { Type =
        { hosts : Text
    , vars : Optional ({ jupyter_ip : Text, jupyter_domains : List Text })
    , pre_tasks : Optional (List ({ name : Text, tags : List Text, shell : Optional Text, register : Optional Text, changed_when : Optional (List Text), failed_when : Optional (List Text), file : Optional ({ path : Text, state : Text, owner : Text, group : Text }), lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, `1_docker` : { path : Text, pool : Text, source : Text, type : Text }, `2_flexextract` : { path : Text, source : Text, type : Text, recursive : Text }, `3_flexextract_meteo` : { path : Text, source : Text, type : Text }, `4_output` : { path : Text, source : Text, type : Text, readonly : Text }, `5_meteo` : { path : Text, source : Text, type : Text, readonly : Text }, `6_ct2018` : { path : Text, source : Text, type : Text, readonly : Text }, `7_vprm` : { path : Text, source : Text, readonly : Text, type : Text }, `8_stiltweb` : { path : Text, source : Text, type : Text, readonly : Text }, `9_cupcake` : { path : Text, source : Text, type : Text, readonly : Text } }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }) }))
    , roles : List ({ role : Text, lxd_forward_ip : Optional Text, lxd_forward_name : Optional Text, tags : Optional Text, certbot_name : Optional Text, certbot_domains : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text, jupyter_domain : Optional Text, jupyter_cert_name : Optional Text, jupyter_port : Optional Natural, user_disable_coredump : Optional Bool, user_conf : Optional Text, flexpart_install_run : Optional Bool, jupyter_admins : Optional Text, jupyter_backup_enable : Optional Bool })
    , tasks : Optional (List ({ name : Text, tags : Text, become : Bool, become_user : Text, `community.general.docker_login` : { registry_url : Text, username : Text, password : Text } }))
  }
    , default =
        { vars = None ({ jupyter_ip : Text, jupyter_domains : List Text })
    , pre_tasks = None (List ({ name : Text, tags : List Text, shell : Optional Text, register : Optional Text, changed_when : Optional (List Text), failed_when : Optional (List Text), file : Optional ({ path : Text, state : Text, owner : Text, group : Text }), lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, `1_docker` : { path : Text, pool : Text, source : Text, type : Text }, `2_flexextract` : { path : Text, source : Text, type : Text, recursive : Text }, `3_flexextract_meteo` : { path : Text, source : Text, type : Text }, `4_output` : { path : Text, source : Text, type : Text, readonly : Text }, `5_meteo` : { path : Text, source : Text, type : Text, readonly : Text }, `6_ct2018` : { path : Text, source : Text, type : Text, readonly : Text }, `7_vprm` : { path : Text, source : Text, readonly : Text, type : Text }, `8_stiltweb` : { path : Text, source : Text, type : Text, readonly : Text }, `9_cupcake` : { path : Text, source : Text, type : Text, readonly : Text } }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }) }))
    , tasks = None (List ({ name : Text, tags : Text, become : Bool, become_user : Text, `community.general.docker_login` : { registry_url : Text, username : Text, password : Text } }))
  }
    }

in  [
    Play::{
      hosts = "fsicos3",
      vars = Some {
        jupyter_ip = "{{ _lxd.addresses.eth0 | first }}"
      , jupyter_domains = [ "flexpart.icos-cp.eu" ]
    },
      pre_tasks = Some [
        {
          name = "Create flexpart docker storage volume",
          tags = [ "pool" ],
          shell = Some "/snap/bin/lxc storage volume create docker flexpart_docker",
          register = Some "_r",
          changed_when = Some [ "\"Storage volume flexpart_docker created\" in _r.stdout" ],
          failed_when = Some [
            "_r.rc != 0"
          , "\"Error: Volume by that name already exists\" not in _r.stderr"
        ],
          file = None ({ path : Text, state : Text, owner : Text, group : Text }),
          lxd_container = None ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, `1_docker` : { path : Text, pool : Text, source : Text, type : Text }, `2_flexextract` : { path : Text, source : Text, type : Text, recursive : Text }, `3_flexextract_meteo` : { path : Text, source : Text, type : Text }, `4_output` : { path : Text, source : Text, type : Text, readonly : Text }, `5_meteo` : { path : Text, source : Text, type : Text, readonly : Text }, `6_ct2018` : { path : Text, source : Text, type : Text, readonly : Text }, `7_vprm` : { path : Text, source : Text, readonly : Text, type : Text }, `8_stiltweb` : { path : Text, source : Text, type : Text, readonly : Text }, `9_cupcake` : { path : Text, source : Text, type : Text, readonly : Text } }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural })
        }
      , {
          name = "Create /data/flexpart/output directory",
          tags = [ "mkdir" ],
          shell = None Text,
          register = None Text,
          changed_when = None (List Text),
          failed_when = None (List Text),
          file = Some {
            path = "/data/flexpart/output"
          , state = "directory"
          , owner = "{{ 1001000 }}"
          , group = "{{ 1001000 }}"
        },
          lxd_container = None ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, `1_docker` : { path : Text, pool : Text, source : Text, type : Text }, `2_flexextract` : { path : Text, source : Text, type : Text, recursive : Text }, `3_flexextract_meteo` : { path : Text, source : Text, type : Text }, `4_output` : { path : Text, source : Text, type : Text, readonly : Text }, `5_meteo` : { path : Text, source : Text, type : Text, readonly : Text }, `6_ct2018` : { path : Text, source : Text, type : Text, readonly : Text }, `7_vprm` : { path : Text, source : Text, readonly : Text, type : Text }, `8_stiltweb` : { path : Text, source : Text, type : Text, readonly : Text }, `9_cupcake` : { path : Text, source : Text, type : Text, readonly : Text } }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural })
        }
      , {
          name = "Create the flexpart container",
          tags = [ "lxd", "nginx" ],
          shell = None Text,
          register = Some "_lxd",
          changed_when = None (List Text),
          failed_when = None (List Text),
          file = None ({ path : Text, state : Text, owner : Text, group : Text }),
          lxd_container = Some {
            name = "flexpart"
          , state = "started"
          , profiles = [ "default", "ssh_root", "icosdata" ]
          , source = {
              type = "image"
            , mode = "pull"
            , server = "https://cloud-images.ubuntu.com/releases"
            , protocol = "simplestreams"
            , alias = "20.04"
          }
          , config = { `security.nesting` = "true", `limits.cpu` = "50", `limits.memory` = "220GB" }
          , devices = {
              root = {
                path = "/"
              , pool = "default"
              , type = "disk"
              , size = "50GB"
            }
            , `1_docker` = {
                path = "/var/lib/docker"
              , pool = "docker"
              , source = "flexpart_docker"
              , type = "disk"
            }
            , `2_flexextract` = {
                path = "/data/flexextract"
              , source = "/data/flexextract"
              , type = "disk"
              , recursive = "true"
            }
            , `3_flexextract_meteo` = {
                path = "/data/flexextract/meteo"
              , source = "/nfs/flexextract_meteo"
              , type = "disk"
            }
            , `4_output` = {
                path = "/data/flexpart/output"
              , source = "/data/flexpart/output"
              , type = "disk"
              , readonly = "False"
            }
            , `5_meteo` = {
                path = "/data/flexpart/meteo"
              , source = "/data/flexpart/meteo"
              , type = "disk"
              , readonly = "True"
            }
            , `6_ct2018` = {
                path = "/data/flexpart/CT2018"
              , source = "/data/flexpart/CT2018"
              , type = "disk"
              , readonly = "True"
            }
            , `7_vprm` = {
                path = "/data/VPRM2007n"
              , source = "/pool/ute/stilt/VPRM/VPRM_ECMWF/VPRM2007n"
              , readonly = "True"
              , type = "disk"
            }
            , `8_stiltweb` = {
                path = "/data/stiltweb"
              , source = "/data/stiltweb"
              , type = "disk"
              , readonly = "True"
            }
            , `9_cupcake` = {
                path = "/data/cupcake"
              , source = "/data/cupcake"
              , type = "disk"
              , readonly = "False"
            }
          }
          , wait_for_ipv4_addresses = True
          , wait_for_ipv4_interfaces = "eth0"
          , timeout = 60
        }
        }
    ],
      roles = [
        {
          role = "icos.lxd_forward",
          lxd_forward_ip = Some "{{ _lxd.addresses.eth0 | first }}",
          lxd_forward_name = Some "flexpart",
          tags = None Text,
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          jupyter_domain = None Text,
          jupyter_cert_name = None Text,
          jupyter_port = None Natural,
          user_disable_coredump = None Bool,
          user_conf = None Text,
          flexpart_install_run = None Bool,
          jupyter_admins = None Text,
          jupyter_backup_enable = None Bool
        }
      , {
          role = "icos.certbot2",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          tags = Some "cert",
          certbot_name = Some "flexpart",
          certbot_domains = Some "{{ jupyter_domains }}",
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          jupyter_domain = None Text,
          jupyter_cert_name = None Text,
          jupyter_port = None Natural,
          user_disable_coredump = None Bool,
          user_conf = None Text,
          flexpart_install_run = None Bool,
          jupyter_admins = None Text,
          jupyter_backup_enable = None Bool
        }
      , {
          role = "icos.nginxsite",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          tags = Some "nginx",
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = Some "flexpart",
          nginxsite_file = Some "files/jupyter.conf",
          jupyter_domain = Some "{{ jupyter_domains | first }}",
          jupyter_cert_name = Some "flexpart",
          jupyter_port = Some 8000,
          user_disable_coredump = None Bool,
          user_conf = None Text,
          flexpart_install_run = None Bool,
          jupyter_admins = None Text,
          jupyter_backup_enable = None Bool
        }
    ]
    }
  , Play::{
      hosts = "flexpart",
      roles = [
        {
          role = "icos.lxd_guest",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          tags = Some "guest",
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          jupyter_domain = None Text,
          jupyter_cert_name = None Text,
          jupyter_port = None Natural,
          user_disable_coredump = Some True,
          user_conf = Some "{{ vault_ganymede_user_conf }}",
          flexpart_install_run = None Bool,
          jupyter_admins = None Text,
          jupyter_backup_enable = None Bool
        }
      , {
          role = "icos.docker",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          tags = Some "docker",
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          jupyter_domain = None Text,
          jupyter_cert_name = None Text,
          jupyter_port = None Natural,
          user_disable_coredump = None Bool,
          user_conf = None Text,
          flexpart_install_run = None Bool,
          jupyter_admins = None Text,
          jupyter_backup_enable = None Bool
        }
      , {
          role = "icos.flexpart",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          tags = Some "flexpart",
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          jupyter_domain = None Text,
          jupyter_cert_name = None Text,
          jupyter_port = None Natural,
          user_disable_coredump = None Bool,
          user_conf = None Text,
          flexpart_install_run = Some True,
          jupyter_admins = None Text,
          jupyter_backup_enable = None Bool
        }
      , {
          role = "icos.jupyter",
          lxd_forward_ip = None Text,
          lxd_forward_name = None Text,
          tags = Some "jupyter",
          certbot_name = None Text,
          certbot_domains = None Text,
          nginxsite_name = None Text,
          nginxsite_file = None Text,
          jupyter_domain = None Text,
          jupyter_cert_name = None Text,
          jupyter_port = None Natural,
          user_disable_coredump = None Bool,
          user_conf = None Text,
          flexpart_install_run = None Bool,
          jupyter_admins = Some "{{ vault_flexpart_admins }}",
          jupyter_backup_enable = Some False
        }
    ],
      tasks = Some [
        {
          name = "Login to registry"
        , tags = "login"
        , become = True
        , become_user = "root"
        , `community.general.docker_login` = {
            registry_url = "registry.icos-cp.eu"
          , username = "docker"
          , password = "{{ vault_registry_pass }}"
        }
      }
    ]
    }
]
