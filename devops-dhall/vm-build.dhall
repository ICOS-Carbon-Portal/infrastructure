-- Auto-generated from vm-build.yml

let Play =
    { Type =
        { hosts : Text
    , roles : List ({ role : Text, lxd_vm_name : Optional Text, lxd_vm_docker : Optional Bool, tags : Optional Text })
    , tags : Optional Text
    , vars : Optional ({ sbt_openjdk_version : Natural })
    , tasks : Optional (List ({ name : Text, `ansible.builtin.apt_key` : Optional ({ keyserver : Text, id : Text }), apt_repository : Optional ({ filename : Text, repo : Text }), apt : Optional ({ name : List Text, update_cache : Optional Bool }), user : Optional ({ name : Text, shell : Text }), `ansible.builtin.shell` : Optional Text, args : Optional ({ creates : Text }), changed_when : Optional Bool }))
  }
    , default =
        { tags = None Text
    , vars = None ({ sbt_openjdk_version : Natural })
    , tasks = None (List ({ name : Text, `ansible.builtin.apt_key` : Optional ({ keyserver : Text, id : Text }), apt_repository : Optional ({ filename : Text, repo : Text }), apt : Optional ({ name : List Text, update_cache : Optional Bool }), user : Optional ({ name : Text, shell : Text }), `ansible.builtin.shell` : Optional Text, args : Optional ({ creates : Text }), changed_when : Optional Bool }))
  }
    }

in  [
    Play::{
      hosts = "fsicos2",
      roles = [
        {
          role = "icos.lxd_vm",
          lxd_vm_name = Some "build",
          lxd_vm_docker = Some True,
          tags = None Text
        }
    ]
    }
  , Play::{
      hosts = "build",
      roles = [
        {
          role = "icos.lxd_guest",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          tags = Some "guest"
        }
    ]
    }
  , Play::{
      hosts = "build",
      roles = [
        {
          role = "icos.docker",
          lxd_vm_name = None Text,
          lxd_vm_docker = None Bool,
          tags = Some "docker"
        }
    ],
      tags = Some "setup",
      vars = Some { sbt_openjdk_version = 11 },
      tasks = Some [
        {
          name = "Add the scala-sbt.org key",
          `ansible.builtin.apt_key` = Some {
            keyserver = "keyserver.ubuntu.com"
          , id = "2EE0EA64E40A89B84B2DF73499E82A75642AC823"
        },
          apt_repository = None ({ filename : Text, repo : Text }),
          apt = None ({ name : List Text, update_cache : Optional Bool }),
          user = None ({ name : Text, shell : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ creates : Text }),
          changed_when = None Bool
        }
      , {
          name = "Add scalasbt apt repository",
          `ansible.builtin.apt_key` = None ({ keyserver : Text, id : Text }),
          apt_repository = Some {
            filename = "scalasbt"
          , repo = ''
            deb https://repo.scala-sbt.org/scalasbt/debian all main

          ''
        },
          apt = None ({ name : List Text, update_cache : Optional Bool }),
          user = None ({ name : Text, shell : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ creates : Text }),
          changed_when = None Bool
        }
      , {
          name = "Install sbt and openjdk",
          `ansible.builtin.apt_key` = None ({ keyserver : Text, id : Text }),
          apt_repository = None ({ filename : Text, repo : Text }),
          apt = Some { name = [ "openjdk-11-jdk-headless", "sbt" ], update_cache = None Bool },
          user = None ({ name : Text, shell : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ creates : Text }),
          changed_when = None Bool
        }
      , {
          name = "Create build user",
          `ansible.builtin.apt_key` = None ({ keyserver : Text, id : Text }),
          apt_repository = None ({ filename : Text, repo : Text }),
          apt = None ({ name : List Text, update_cache : Optional Bool }),
          user = Some { name = "build", shell = "/bin/bash" },
          `ansible.builtin.shell` = None Text,
          args = None ({ creates : Text }),
          changed_when = None Bool
        }
      , {
          name = "Add nodesource apt repo",
          `ansible.builtin.apt_key` = None ({ keyserver : Text, id : Text }),
          apt_repository = None ({ filename : Text, repo : Text }),
          apt = None ({ name : List Text, update_cache : Optional Bool }),
          user = None ({ name : Text, shell : Text }),
          `ansible.builtin.shell` = Some ''
          curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

        '',
          args = Some { creates = "/etc/apt/sources.list.d/nodesource.list" },
          changed_when = Some False
        }
      , {
          name = "Install nodejs",
          `ansible.builtin.apt_key` = None ({ keyserver : Text, id : Text }),
          apt_repository = None ({ filename : Text, repo : Text }),
          apt = Some { name = [ "nodejs" ], update_cache = Some True },
          user = None ({ name : Text, shell : Text }),
          `ansible.builtin.shell` = None Text,
          args = None ({ creates : Text }),
          changed_when = None Bool
        }
    ]
    }
]
