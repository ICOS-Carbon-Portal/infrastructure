-- Auto-generated from ../devops/vm-cities.yml

let Play =
    { Type =
        { hosts : Text
    , vars : Optional ({ pool_name : Text, pool_path : Text, data_path : Text, docker_path : Text, data_fast_path : Text })
    , pre_tasks : Optional (List ({ name : Text, file : Optional ({ path : Text, state : Text, owner : Optional Natural, group : Optional Natural }), loop : Optional (List Text), shell : Optional Text, register : Optional Text, changed_when : Optional (List Text) }))
    , roles : List ({ name : Optional Text, role : Text, vars : Optional ({ lxd_vm_name : Text, lxd_vm_ubuntu_version : Text, lxd_vm_root_pool : Text, lxd_vm_config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, lxd_vm_devices : { data : { path : Text, source : Text, type : Text }, data_fast : { path : Text, source : Text, type : Text }, docker : { path : Text, source : Text, type : Text } } }), tags : Optional Text })
    , tasks : Optional (List ({ name : Text, shell : Text, changed_when : Bool }))
  }
    , default =
        { vars = None ({ pool_name : Text, pool_path : Text, data_path : Text, docker_path : Text, data_fast_path : Text })
    , pre_tasks = None (List ({ name : Text, file : Optional ({ path : Text, state : Text, owner : Optional Natural, group : Optional Natural }), loop : Optional (List Text), shell : Optional Text, register : Optional Text, changed_when : Optional (List Text) }))
    , tasks = None (List ({ name : Text, shell : Text, changed_when : Bool }))
  }
    }

in  [
    Play::{
      hosts = "fsicos2",
      vars = Some {
        pool_name = "cities"
      , pool_path = "/disk/data/lxd/storage_pools/cities"
      , data_path = "/disk/data/cities"
      , docker_path = "/disk/cities_docker"
      , data_fast_path = "/disk/cities_data_fast"
    },
      pre_tasks = Some (let Task =
        { Type =
            { name : Text
        , file : Optional ({ path : Text, state : Text, owner : Optional Natural, group : Optional Natural })
        , loop : Optional (List Text)
        , shell : Optional Text
        , register : Optional Text
        , changed_when : Optional (List Text)
      }
        , default =
            { file = None ({ path : Text, state : Text, owner : Optional Natural, group : Optional Natural })
        , loop = None (List Text)
        , shell = None Text
        , register = None Text
        , changed_when = None (List Text)
      }
        }

    in  [
        Task::{
          name = "Create cities storage_pool directory",
          file = Some {
            path = "{{ pool_path }}"
          , state = "directory"
          , owner = None Natural
          , group = None Natural
        }
        }
      , Task::{
          name = "Create cities directories",
          file = Some {
            path = "{{ item }}"
          , state = "directory"
          , owner = Some 1000000
          , group = Some 1000000
        },
          loop = Some [ "{{ data_path }}", "{{ docker_path }}", "{{ data_fast_path }}" ]
        }
      , Task::{
          name = "Create cities storage pool",
          shell = Some ''
          /snap/bin/lxc storage show {{ pool_name }} > /dev/null 2>&1 || \ /snap/bin/lxc storage create {{ pool_name }} dir source="{{ pool_path}}"

        '',
          register = Some "_r",
          changed_when = Some [ "(\"Storage pool %s created\" % pool_name) in _r.stdout" ]
        }
    ]),
      roles = let Role =
        { Type =
            { name : Optional Text
        , role : Text
        , vars : Optional ({ lxd_vm_name : Text, lxd_vm_ubuntu_version : Text, lxd_vm_root_pool : Text, lxd_vm_config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, lxd_vm_devices : { data : { path : Text, source : Text, type : Text }, data_fast : { path : Text, source : Text, type : Text }, docker : { path : Text, source : Text, type : Text } } })
        , tags : Optional Text
      }
        , default =
            { name = None Text
        , vars = None ({ lxd_vm_name : Text, lxd_vm_ubuntu_version : Text, lxd_vm_root_pool : Text, lxd_vm_config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, lxd_vm_devices : { data : { path : Text, source : Text, type : Text }, data_fast : { path : Text, source : Text, type : Text }, docker : { path : Text, source : Text, type : Text } } })
        , tags = None Text
      }
        }

    in  [
        Role::{
          name = Some "Create the cities VM",
          role = "icos.lxd_vm",
          vars = Some {
            lxd_vm_name = "cities"
          , lxd_vm_ubuntu_version = "20.04"
          , lxd_vm_root_pool = "cities"
          , lxd_vm_config = { `security.nesting` = "true", `limits.cpu` = "16", `limits.memory` = "64GB" }
          , lxd_vm_devices = {
              data = { path = "/data", source = "{{ data_path }}", type = "disk" }
            , data_fast = {
                path = "{{ cities_datafast_path }}"
              , source = "{{ data_fast_path }}"
              , type = "disk"
            }
            , docker = { path = "/var/lib/docker", source = "{{ docker_path }}", type = "disk" }
          }
        }
        }
    ]
    }
  , Play::{
      hosts = "cities",
      roles = let Role =
        { Type =
            { name : Optional Text
        , role : Text
        , vars : Optional ({ lxd_vm_name : Text, lxd_vm_ubuntu_version : Text, lxd_vm_root_pool : Text, lxd_vm_config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, lxd_vm_devices : { data : { path : Text, source : Text, type : Text }, data_fast : { path : Text, source : Text, type : Text }, docker : { path : Text, source : Text, type : Text } } })
        , tags : Optional Text
      }
        , default =
            { name = None Text
        , vars = None ({ lxd_vm_name : Text, lxd_vm_ubuntu_version : Text, lxd_vm_root_pool : Text, lxd_vm_config : { `security.nesting` : Text, `limits.cpu` : Text, `limits.memory` : Text }, lxd_vm_devices : { data : { path : Text, source : Text, type : Text }, data_fast : { path : Text, source : Text, type : Text }, docker : { path : Text, source : Text, type : Text } } })
        , tags = None Text
      }
        }

    in  [
        Role::{ role = "icos.lxd_guest", tags = Some "guest" }
      , Role::{ role = "icos.docker2", tags = Some "docker" }
    ],
      tasks = Some [
        {
          name = "Check /data for write access"
        , shell = ''
          rm -- $(mktemp -p /data)

        ''
        , changed_when = False
      }
    ]
    }
]
