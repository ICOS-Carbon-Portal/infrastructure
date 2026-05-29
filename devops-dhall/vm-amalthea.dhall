-- Auto-generated from ../devops/vm-amalthea.yml

let Play =
    { Type =
        { hosts : Text
    , vars : Optional ({ amalthea_ip : Text })
    , tasks : List ({ name : Text, tags : Optional (List Text), include_role : Optional ({ name : Text, public : Bool }), vars : Optional ({ zfsdocker_name : Text, zfsdocker_size : Text }), lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, flexextract : { path : Text, source : Text, type : Text, readonly : Text } }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }), register : Optional Text, iptables_raw : Optional ({ name : Text, table : Text, rules : Text }), debug : Optional ({ msg : Text }) })
    , roles : Optional (List ({ role : Text, tags : Text, superuser_disable_coredump : Optional Bool, superuser_list : Optional (List ({ name : Text, key : Text })) }))
  }
    , default =
        { vars = None ({ amalthea_ip : Text })
    , roles = None (List ({ role : Text, tags : Text, superuser_disable_coredump : Optional Bool, superuser_list : Optional (List ({ name : Text, key : Text })) }))
  }
    }

in  [
    Play::{
      hosts = "fsicos3",
      vars = Some { amalthea_ip = "{{ _lxd.addresses.eth0 | first }}" },
      tasks = let Entry =
        { Type =
            { name : Text
        , tags : Optional (List Text)
        , include_role : Optional ({ name : Text, public : Bool })
        , vars : Optional ({ zfsdocker_name : Text, zfsdocker_size : Text })
        , lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, flexextract : { path : Text, source : Text, type : Text, readonly : Text } }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural })
        , register : Optional Text
        , iptables_raw : Optional ({ name : Text, table : Text, rules : Text })
        , debug : Optional ({ msg : Text })
      }
        , default =
            { tags = None (List Text)
        , include_role = None ({ name : Text, public : Bool })
        , vars = None ({ zfsdocker_name : Text, zfsdocker_size : Text })
        , lxd_container = None ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, flexextract : { path : Text, source : Text, type : Text, readonly : Text } }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural })
        , register = None Text
        , iptables_raw = None ({ name : Text, table : Text, rules : Text })
        , debug = None ({ msg : Text })
      }
        }

    in  [
        Entry::{
          name = "Create storage for docker",
          tags = Some [ "zfs", "lxd" ],
          include_role = Some { name = "icos.zfsdocker", public = True },
          vars = Some { zfsdocker_name = "amalthea", zfsdocker_size = "50G" }
        }
      , Entry::{
          name = "Create the amalthea container",
          tags = Some [ "lxd", "iptables" ],
          lxd_container = Some {
            name = "amalthea"
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
              , size = "100GB"
            }
            , docker = {
                path = "/var/lib/docker"
              , source = "{{ zfsdocker_zvol }}"
              , type = "disk"
              , `raw.mount.options` = "user_subvol_rm_allowed"
            }
            , flexextract = {
                path = "/data/flexextract"
              , source = "/nfs/flexextract"
              , type = "disk"
              , readonly = "False"
            }
          }
          , config = { `security.nesting` = "true", `limits.cpu` = "32", `limits.memory` = "256GB" }
          , wait_for_ipv4_addresses = True
          , wait_for_ipv4_interfaces = "eth0"
          , timeout = 60
        },
          register = Some "_lxd"
        }
      , Entry::{
          name = "SSH forward to amalthea",
          tags = Some [ "iptables" ],
          iptables_raw = Some {
            name = "forward_ssh_to_amalthea"
          , table = "nat"
          , rules = "-A PREROUTING -p tcp --dport {{ hostvars['amalthea'].ansible_port }} -j DNAT --to-destination {{ amalthea_ip }}:22"
        }
        }
    ]
    }
  , Play::{
      hosts = "amalthea",
      tasks = let Entry =
        { Type =
            { name : Text
        , tags : Optional (List Text)
        , include_role : Optional ({ name : Text, public : Bool })
        , vars : Optional ({ zfsdocker_name : Text, zfsdocker_size : Text })
        , lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, flexextract : { path : Text, source : Text, type : Text, readonly : Text } }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural })
        , register : Optional Text
        , iptables_raw : Optional ({ name : Text, table : Text, rules : Text })
        , debug : Optional ({ msg : Text })
      }
        , default =
            { tags = None (List Text)
        , include_role = None ({ name : Text, public : Bool })
        , vars = None ({ zfsdocker_name : Text, zfsdocker_size : Text })
        , lxd_container = None ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, flexextract : { path : Text, source : Text, type : Text, readonly : Text } }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural })
        , register = None Text
        , iptables_raw = None ({ name : Text, table : Text, rules : Text })
        , debug = None ({ msg : Text })
      }
        }

    in  [
        Entry::{
          name = "Print ssh config",
          debug = Some {
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
    ],
      roles = Some (let Role =
        { Type =
            { role : Text
        , tags : Text
        , superuser_disable_coredump : Optional Bool
        , superuser_list : Optional (List ({ name : Text, key : Text }))
      }
        , default =
            { superuser_disable_coredump = None Bool
        , superuser_list = None (List ({ name : Text, key : Text }))
      }
        }

    in  [
        Role::{ role = "icos.lxd_guest", tags = "guest" }
      , Role::{
          role = "icos.superuser",
          tags = "superuser",
          superuser_disable_coredump = Some True,
          superuser_list = Some [
            { name = "ubuntu", key = "{{ vault_amalthea_ssh_keys }}" }
        ]
        }
    ])
    }
]
