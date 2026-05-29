-- Auto-generated from ../devops/vm-erddap.yml

let Play =
    { Type =
        { hosts : Text
    , vars : Optional ({ certbot_name : Text, certbot_domains : List Text })
    , pre_tasks : Optional (List ({ name : Text, tags : Optional Text, shell : Optional Text, register : Text, changed_when : Optional (List Text), lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, type : Text, pool : Text, size : Text }, dataAppStorage : { path : Text, source : Text, readonly : Text, type : Text } }, wait_for_ipv4_addresses : Bool, timeout : Natural }) }))
    , roles : List ({ role : Text, lxd_forward_ip : Optional Text, lxd_forward_name : Optional Text, tags : Optional Text, nginxsite_name : Optional Text, nginxsite_file : Optional Text })
    , tasks : Optional (List ({ name : Text, tags : Text, debug : { msg : Text } }))
  }
    , default =
        { vars = None ({ certbot_name : Text, certbot_domains : List Text })
    , pre_tasks = None (List ({ name : Text, tags : Optional Text, shell : Optional Text, register : Text, changed_when : Optional (List Text), lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, type : Text, pool : Text, size : Text }, dataAppStorage : { path : Text, source : Text, readonly : Text, type : Text } }, wait_for_ipv4_addresses : Bool, timeout : Natural }) }))
    , tasks = None (List ({ name : Text, tags : Text, debug : { msg : Text } }))
  }
    }

in  [
    Play::{
      hosts = "fsicos2",
      vars = Some {
        certbot_name = "erddap"
      , certbot_domains = [ "erddap.icos-cp.eu", "test-erddap.icos-cp.eu", "bluecloud.icos-cp.eu" ]
    },
      pre_tasks = Some (let Task =
        { Type =
            { name : Text
        , tags : Optional Text
        , shell : Optional Text
        , register : Text
        , changed_when : Optional (List Text)
        , lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, type : Text, pool : Text, size : Text }, dataAppStorage : { path : Text, source : Text, readonly : Text, type : Text } }, wait_for_ipv4_addresses : Bool, timeout : Natural })
      }
        , default =
            { tags = None Text
        , shell = None Text
        , changed_when = None (List Text)
        , lxd_container = None ({ name : Text, state : Text, profiles : List Text, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, type : Text, pool : Text, size : Text }, dataAppStorage : { path : Text, source : Text, readonly : Text, type : Text } }, wait_for_ipv4_addresses : Bool, timeout : Natural })
      }
        }

    in  [
        Task::{
          name = "Create erddap storage pool",
          tags = Some "pool",
          shell = Some "/snap/bin/lxc storage show erddap > /dev/null 2>&1 || /snap/bin/lxc storage create erddap btrfs size=50GB",
          register = "_r",
          changed_when = Some [ "\"Storage pool erddap created\" in _r.stdout" ]
        }
      , Task::{
          name = "Create the erddap container",
          register = "_lxd",
          lxd_container = Some {
            name = "erddap"
          , state = "started"
          , profiles = [ "default", "ssh_root" ]
          , config = { `security.nesting` = "true", `limits.cpu` = "2", `limits.memory` = "20GB" }
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
              , type = "disk"
              , pool = "erddap"
              , size = "50GB"
            }
            , dataAppStorage = {
                path = "/data/dataAppStorage"
              , source = "/disk/data/dataAppStorage"
              , readonly = "1"
              , type = "disk"
            }
          }
          , wait_for_ipv4_addresses = True
          , timeout = 600
        }
        }
    ]),
      roles = let Role =
        { Type =
            { role : Text
        , lxd_forward_ip : Optional Text
        , lxd_forward_name : Optional Text
        , tags : Optional Text
        , nginxsite_name : Optional Text
        , nginxsite_file : Optional Text
      }
        , default =
            { lxd_forward_ip = None Text
        , lxd_forward_name = None Text
        , tags = None Text
        , nginxsite_name = None Text
        , nginxsite_file = None Text
      }
        }

    in  [
        Role::{
          role = "icos.lxd_forward",
          lxd_forward_ip = Some "{{ _lxd.addresses.eth0 | first }}",
          lxd_forward_name = Some "erddap"
        }
      , Role::{ role = "icos.certbot2", tags = Some "cert" }
      , Role::{
          role = "icos.nginxsite",
          tags = Some "nginx",
          nginxsite_name = Some "erddap",
          nginxsite_file = Some "files/erddap.conf"
        }
    ]
    }
  , Play::{
      hosts = "erddap",
      roles = let Role =
        { Type =
            { role : Text
        , lxd_forward_ip : Optional Text
        , lxd_forward_name : Optional Text
        , tags : Optional Text
        , nginxsite_name : Optional Text
        , nginxsite_file : Optional Text
      }
        , default =
            { lxd_forward_ip = None Text
        , lxd_forward_name = None Text
        , tags = None Text
        , nginxsite_name = None Text
        , nginxsite_file = None Text
      }
        }

    in  [
        Role::{ role = "icos.lxd_guest", tags = Some "guest" }
    ],
      tasks = Some [
        {
          name = "Print ssh config"
        , tags = "howto"
        , debug = {
            msg = ''
            # Put this in $HOME/.ssh/config,
            # then execute "ssh {{ inventory_hostname }}"
            Host {{ inventory_hostname }}
              HostName {{ ansible_host }}
              Port {{ ansible_port }}
              User ubuntu
            # Or execute the following command:
            # ssh -p {{ ansible_port }} ubuntu@{{ ansible_host }}

          ''
        }
      }
    ]
    }
]
