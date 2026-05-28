-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , `ansible.builtin.shell` : Optional Text
    , changed_when : Optional Bool
    , register : Optional Text
    , failed_when : Optional Text
    , import_tasks : Optional Text
    , when : Optional Text
    , fail : Optional ({ msg : Text })
    , apt : Optional ({ name : List Text, state : Optional Text })
    , systemd : Optional ({ name : Text, state : Text, enabled : Bool })
    , copy : Optional ({ src : Text, dest : Text })
    , notify : Optional Text
    , tags : Optional Text
    , import_role : Optional Text
  }
    , default =
        { name = None Text
    , `ansible.builtin.shell` = None Text
    , changed_when = None Bool
    , register = None Text
    , failed_when = None Text
    , import_tasks = None Text
    , when = None Text
    , fail = None ({ msg : Text })
    , apt = None ({ name : List Text, state : Optional Text })
    , systemd = None ({ name : Text, state : Text, enabled : Bool })
    , copy = None ({ src : Text, dest : Text })
    , notify = None Text
    , tags = None Text
    , import_role = None Text
  }
    }

in  [
    Item::{
      name = Some "Fail if docker.io is apt-installed",
      `ansible.builtin.shell` = Some ''
      dpkg --get-selections docker.io | grep -vq '\binstall'

    '',
      changed_when = Some False,
      register = Some "r",
      failed_when = Some "r.rc == 0"
    }
  , Item::{ import_tasks = Some "debian.yml", when = Some "ansible_distribution == \"Debian\"" }
  , Item::{ import_tasks = Some "ubuntu.yml", when = Some "ansible_distribution == \"Ubuntu\"" }
  , Item::{
      name = Some "Fail if we're not on a supported distribution",
      when = Some "ansible_distribution not in ('Debian', 'Ubuntu')",
      fail = Some { msg = "This role currently only support Debian and Ubuntu" }
    }
  , Item::{
      name = Some "Uninstall docker-compose version 1",
      apt = Some { name = [ "docker-compose" ], state = Some "absent" }
    }
  , Item::{
      name = Some "Install docker and docker-compose",
      apt = Some {
        name = [
          "docker-ce"
        , "docker-ce-cli"
        , "containerd.io"
        , "docker-buildx-plugin"
        , "docker-compose-plugin"
      ]
      , state = None Text
    }
    }
  , Item::{
      name = Some "Make sure docker is started",
      systemd = Some { name = "docker", state = "started", enabled = True }
    }
  , Item::{
      name = Some "Install docker configuration",
      copy = Some { src = "daemon.json", dest = "/etc/docker/" },
      notify = Some "reload docker"
    }
  , Item::{
      import_tasks = Some "cleanup.yml",
      when = Some "docker_periodic_cleanup",
      tags = Some "docker_cleanup"
    }
  , Item::{ tags = Some "docker_utils", import_role = Some "name=icos.docker_utils" }
  , Item::{ import_tasks = Some "test.yml", tags = Some "docker_test" }
  , Item::{ import_tasks = Some "just.yml", tags = Some "docker_just" }
]
