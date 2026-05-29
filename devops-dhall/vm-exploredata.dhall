-- Auto-generated from ../devops/vm-exploredata.yml

let Play =
    { Type =
        { hosts : Text
    , vars : { exploredata_ip : Optional Text, exploredata_password : Optional Text, exploredata_max_notebooks : Optional Natural }
    , tasks : Optional (List ({ name : Optional Text, tags : List Text, include_role : Optional ({ name : Text, public : Optional Bool }), vars : Optional ({ zfsdocker_name : Optional Text, zfsdocker_size : Optional Text, lxd_forward_name : Optional Text, lxd_forward_ip : Optional Text, certbot_name : Optional Text, certbot_domains : Optional (List Text), nginxsite_name : Optional Text, nginxsite_file : Optional Text, exploredata_name : Optional Text, exploredata_port : Optional Natural, exploredata_host : Optional Text, exploredata_domains : Optional (List Text) }), lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, data : { path : Text, source : Text, type : Text, recursive : Text } }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text, `limits.memory.enforce` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }), register : Optional Text, when : Optional Text }))
    , roles : Optional (List ({ role : Text, tags : Text }))
  }
    , default =
        { tasks = None (List ({ name : Optional Text, tags : List Text, include_role : Optional ({ name : Text, public : Optional Bool }), vars : Optional ({ zfsdocker_name : Optional Text, zfsdocker_size : Optional Text, lxd_forward_name : Optional Text, lxd_forward_ip : Optional Text, certbot_name : Optional Text, certbot_domains : Optional (List Text), nginxsite_name : Optional Text, nginxsite_file : Optional Text, exploredata_name : Optional Text, exploredata_port : Optional Natural, exploredata_host : Optional Text, exploredata_domains : Optional (List Text) }), lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, data : { path : Text, source : Text, type : Text, recursive : Text } }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text, `limits.memory.enforce` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }), register : Optional Text, when : Optional Text }))
    , roles = None (List ({ role : Text, tags : Text }))
  }
    }

in  [
    Play::{
      hosts = "fsicos3",
      vars = {
        exploredata_ip = Some "{{ _lxd.addresses.eth0 | first }}"
      , exploredata_password = None Text
      , exploredata_max_notebooks = None Natural
    },
      tasks = Some [
        {
          name = Some "Create storage for docker",
          tags = [ "zfs", "lxd" ],
          include_role = Some { name = "icos.zfsdocker", public = Some True },
          vars = Some {
            zfsdocker_name = Some "exploredata"
          , zfsdocker_size = Some "50G"
          , lxd_forward_name = None Text
          , lxd_forward_ip = None Text
          , certbot_name = None Text
          , certbot_domains = None (List Text)
          , nginxsite_name = None Text
          , nginxsite_file = None Text
          , exploredata_name = None Text
          , exploredata_port = None Natural
          , exploredata_host = None Text
          , exploredata_domains = None (List Text)
        },
          lxd_container = None ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, data : { path : Text, source : Text, type : Text, recursive : Text } }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text, `limits.memory.enforce` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }),
          register = None Text,
          when = None Text
        }
      , {
          name = Some "Create the exploredata container",
          tags = [ "lxd", "nginx", "forward", "iptables" ],
          include_role = None ({ name : Text, public : Optional Bool }),
          vars = None ({ zfsdocker_name : Optional Text, zfsdocker_size : Optional Text, lxd_forward_name : Optional Text, lxd_forward_ip : Optional Text, certbot_name : Optional Text, certbot_domains : Optional (List Text), nginxsite_name : Optional Text, nginxsite_file : Optional Text, exploredata_name : Optional Text, exploredata_port : Optional Natural, exploredata_host : Optional Text, exploredata_domains : Optional (List Text) }),
          lxd_container = Some {
            name = "exploredata"
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
              , size = "100GB"
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
              , recursive = "true"
            }
          }
          , config = {
              `security.nesting` = "true"
            , `limits.cpu` = "10"
            , `limits.memory` = "100GB"
            , `limits.memory.enforce` = "soft"
          }
          , wait_for_ipv4_addresses = True
          , wait_for_ipv4_interfaces = "eth0"
          , timeout = 60
        },
          register = Some "_lxd",
          when = Some "not ansible_check_mode"
        }
      , {
          name = Some "Forward ssh port and create /etc/hosts entry",
          tags = [ "forward" ],
          include_role = Some { name = "icos.lxd_forward", public = None Bool },
          vars = Some {
            zfsdocker_name = None Text
          , zfsdocker_size = None Text
          , lxd_forward_name = Some "exploredata"
          , lxd_forward_ip = Some "{{ exploredata_ip }}"
          , certbot_name = None Text
          , certbot_domains = None (List Text)
          , nginxsite_name = None Text
          , nginxsite_file = None Text
          , exploredata_name = None Text
          , exploredata_port = None Natural
          , exploredata_host = None Text
          , exploredata_domains = None (List Text)
        },
          lxd_container = None ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, data : { path : Text, source : Text, type : Text, recursive : Text } }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text, `limits.memory.enforce` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }),
          register = None Text,
          when = None Text
        }
      , {
          name = None Text,
          tags = [ "cert" ],
          include_role = Some "name=icos.certbot2",
          vars = Some {
            zfsdocker_name = None Text
          , zfsdocker_size = None Text
          , lxd_forward_name = None Text
          , lxd_forward_ip = None Text
          , certbot_name = Some "exploredata"
          , certbot_domains = Some [ "exploredata.icos-cp.eu", "exploretest.icos-cp.eu" ]
          , nginxsite_name = None Text
          , nginxsite_file = None Text
          , exploredata_name = None Text
          , exploredata_port = None Natural
          , exploredata_host = None Text
          , exploredata_domains = None (List Text)
        },
          lxd_container = None ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, data : { path : Text, source : Text, type : Text, recursive : Text } }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text, `limits.memory.enforce` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }),
          register = None Text,
          when = None Text
        }
      , {
          name = Some "Setup exploretest",
          tags = [ "nginx" ],
          include_role = Some { name = "icos.nginxsite", public = None Bool },
          vars = Some {
            zfsdocker_name = None Text
          , zfsdocker_size = None Text
          , lxd_forward_name = None Text
          , lxd_forward_ip = None Text
          , certbot_name = None Text
          , certbot_domains = None (List Text)
          , nginxsite_name = Some "exploredata-test"
          , nginxsite_file = Some "roles/icos.exploredata/templates/exploredata-nginx.conf"
          , exploredata_name = Some "test"
          , exploredata_port = Some 4567
          , exploredata_host = Some "{{ exploredata_ip }}"
          , exploredata_domains = Some [ "exploretest.icos-cp.eu" ]
        },
          lxd_container = None ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, data : { path : Text, source : Text, type : Text, recursive : Text } }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text, `limits.memory.enforce` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }),
          register = None Text,
          when = None Text
        }
      , {
          name = Some "Setup exploredata",
          tags = [ "nginx" ],
          include_role = Some { name = "icos.nginxsite", public = None Bool },
          vars = Some {
            zfsdocker_name = None Text
          , zfsdocker_size = None Text
          , lxd_forward_name = None Text
          , lxd_forward_ip = None Text
          , certbot_name = None Text
          , certbot_domains = None (List Text)
          , nginxsite_name = Some "exploredata-prod"
          , nginxsite_file = Some "roles/icos.exploredata/templates/exploredata-nginx.conf"
          , exploredata_name = Some "prod"
          , exploredata_port = Some 4566
          , exploredata_host = Some "{{ exploredata_ip }}"
          , exploredata_domains = Some [ "exploredata.icos-cp.eu" ]
        },
          lxd_container = None ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { root : { path : Text, pool : Text, type : Text, size : Text }, docker : { path : Text, source : Text, type : Text, `raw.mount.options` : Text }, data : { path : Text, source : Text, type : Text, recursive : Text } }, config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text, `limits.memory.enforce` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }),
          register = None Text,
          when = None Text
        }
    ]
    }
  , Play::{
      hosts = "exploredata",
      vars = {
        exploredata_ip = None Text
      , exploredata_password = Some "{{ vault_exploredata_password }}"
      , exploredata_max_notebooks = Some 100
    },
      roles = Some [
        { role = "icos.lxd_guest", tags = "guest" }
      , { role = "icos.docker", tags = "docker" }
      , { role = "icos.exploredata", tags = "exploredata" }
      , { role = "icos.node_exporter", tags = "node_exporter" }
    ]
    }
]
