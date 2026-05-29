-- Auto-generated from ../devops/vm-registry.yml

let Play =
    { Type =
        { hosts : Text
    , vars : { registry_domain : Text }
    , pre_tasks : Optional (List ({ name : Text, zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : { quota : Text } }), file : Optional ({ path : Text, owner : Natural, group : Natural }), lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { registry : { path : Text, source : Text, type : Text }, root : { path : Text, pool : Text, type : Text, size : Text } }, config : { `limits.memory` : Text, `security.nesting` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }), register : Optional Text }))
    , roles : List ({ role : Text, lxd_forward_ip : Optional Text, lxd_forward_name : Optional Text, tags : Optional (List Text), certbot_name : Optional Text, certbot_domains : Optional (List Text), nginxsite_name : Optional Text, nginxsite_file : Optional Text, registry_host : Optional Text, registry_cert : Optional Text, registry_allow : Optional Text, registry_users : Optional Text })
    , tasks : Optional (List ({ name : Text, `community.general.docker_login` : { registry_url : Text, username : Text, password : Text } }))
  }
    , default =
        { pre_tasks = None (List ({ name : Text, zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : { quota : Text } }), file : Optional ({ path : Text, owner : Natural, group : Natural }), lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { registry : { path : Text, source : Text, type : Text }, root : { path : Text, pool : Text, type : Text, size : Text } }, config : { `limits.memory` : Text, `security.nesting` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural }), register : Optional Text }))
    , tasks = None (List ({ name : Text, `community.general.docker_login` : { registry_url : Text, username : Text, password : Text } }))
  }
    }

in  [
    Play::{
      hosts = "fsicos3",
      vars = { registry_domain = "registry.icos-cp.eu" },
      pre_tasks = Some (let Entry =
        { Type =
            { name : Text
        , zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : { quota : Text } })
        , file : Optional ({ path : Text, owner : Natural, group : Natural })
        , lxd_container : Optional ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { registry : { path : Text, source : Text, type : Text }, root : { path : Text, pool : Text, type : Text, size : Text } }, config : { `limits.memory` : Text, `security.nesting` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural })
        , register : Optional Text
      }
        , default =
            { zfs = None ({ name : Text, state : Text, extra_zfs_properties : { quota : Text } })
        , file = None ({ path : Text, owner : Natural, group : Natural })
        , lxd_container = None ({ name : Text, state : Text, profiles : List Text, source : { type : Text, mode : Text, server : Text, protocol : Text, alias : Text }, devices : { registry : { path : Text, source : Text, type : Text }, root : { path : Text, pool : Text, type : Text, size : Text } }, config : { `limits.memory` : Text, `security.nesting` : Text }, wait_for_ipv4_addresses : Bool, wait_for_ipv4_interfaces : Text, timeout : Natural })
        , register = None Text
      }
        }

    in  [
        Entry::{
          name = "Create storage for registry volumes",
          zfs = Some {
            name = "pool/registry"
          , state = "present"
          , extra_zfs_properties = { quota = "500G" }
        }
        }
      , Entry::{
          name = "Change owner of /pool/registry",
          file = Some { path = "/pool/registry", owner = 1000000, group = 1000000 }
        }
      , Entry::{
          name = "Create the registry container",
          lxd_container = Some {
            name = "registry"
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
              registry = {
                path = "/docker/registry/volumes/registry"
              , source = "/pool/registry"
              , type = "disk"
            }
            , root = {
                path = "/"
              , pool = "default"
              , type = "disk"
              , size = "50GB"
            }
          }
          , config = { `limits.memory` = "8GB", `security.nesting` = "true" }
          , wait_for_ipv4_addresses = True
          , wait_for_ipv4_interfaces = "eth0"
          , timeout = 60
        },
          register = Some "_lxd"
        }
    ]),
      roles = let Role =
        { Type =
            { role : Text
        , lxd_forward_ip : Optional Text
        , lxd_forward_name : Optional Text
        , tags : Optional (List Text)
        , certbot_name : Optional Text
        , certbot_domains : Optional (List Text)
        , nginxsite_name : Optional Text
        , nginxsite_file : Optional Text
        , registry_host : Optional Text
        , registry_cert : Optional Text
        , registry_allow : Optional Text
        , registry_users : Optional Text
      }
        , default =
            { lxd_forward_ip = None Text
        , lxd_forward_name = None Text
        , tags = None (List Text)
        , certbot_name = None Text
        , certbot_domains = None (List Text)
        , nginxsite_name = None Text
        , nginxsite_file = None Text
        , registry_host = None Text
        , registry_cert = None Text
        , registry_allow = None Text
        , registry_users = None Text
      }
        }

    in  [
        Role::{
          role = "icos.lxd_forward",
          lxd_forward_ip = Some "{{ _lxd.addresses.eth0 | first }}",
          lxd_forward_name = Some "registry"
        }
      , Role::{
          role = "icos.certbot2",
          tags = Some [ "cert", "registry" ],
          certbot_name = Some "registry",
          certbot_domains = Some [ "{{ registry_domain }}" ]
        }
      , Role::{
          role = "icos.nginxsite",
          tags = Some [ "registry", "nginx" ],
          nginxsite_name = Some "registry",
          nginxsite_file = Some "roles/icos.registry/templates/registry-nginx.conf",
          registry_host = Some "registry.lxd",
          registry_cert = Some "registry",
          registry_allow = Some "{{ vault_nginx_allow_internal_only }}"
        }
    ]
    }
  , Play::{
      hosts = "registry",
      vars = { registry_domain = "registry.icos-cp.eu" },
      roles = let Role =
        { Type =
            { role : Text
        , lxd_forward_ip : Optional Text
        , lxd_forward_name : Optional Text
        , tags : Optional (List Text)
        , certbot_name : Optional Text
        , certbot_domains : Optional (List Text)
        , nginxsite_name : Optional Text
        , nginxsite_file : Optional Text
        , registry_host : Optional Text
        , registry_cert : Optional Text
        , registry_allow : Optional Text
        , registry_users : Optional Text
      }
        , default =
            { lxd_forward_ip = None Text
        , lxd_forward_name = None Text
        , tags = None (List Text)
        , certbot_name = None Text
        , certbot_domains = None (List Text)
        , nginxsite_name = None Text
        , nginxsite_file = None Text
        , registry_host = None Text
        , registry_cert = None Text
        , registry_allow = None Text
        , registry_users = None Text
      }
        }

    in  [
        Role::{ role = "icos.lxd_guest", tags = Some [ "guest" ] }
      , Role::{ role = "icos.docker2", tags = Some [ "docker" ] }
      , Role::{
          role = "icos.registry",
          tags = Some [ "registry" ],
          registry_users = Some "{{ vault_registry_users }}"
        }
    ],
      tasks = Some [
        {
          name = "Login to registry"
        , `community.general.docker_login` = {
            registry_url = "{{ registry_domain }}"
          , username = "docker"
          , password = "{{ vault_registry_pass }}"
        }
      }
    ]
    }
]
