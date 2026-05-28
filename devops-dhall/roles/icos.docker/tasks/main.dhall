-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , when : Optional Text
    , dpkg_selections : Optional ({ name : Text, selection : Text })
    , loop : Optional (List Text)
    , apt : Optional ({ name : List Text, state : Text, update_cache : Bool })
    , pip : Optional ({ name : Text })
    , copy : Optional ({ src : Text, dest : Text })
    , notify : Optional Text
    , systemd : Optional ({ name : Text, state : Text, enabled : Bool })
    , import_tasks : Optional Text
    , tags : Optional Text
    , import_role : Optional Text
  }
    , default =
        { name = None Text
    , when = None Text
    , dpkg_selections = None ({ name : Text, selection : Text })
    , loop = None (List Text)
    , apt = None ({ name : List Text, state : Text, update_cache : Bool })
    , pip = None ({ name : Text })
    , copy = None ({ src : Text, dest : Text })
    , notify = None Text
    , systemd = None ({ name : Text, state : Text, enabled : Bool })
    , import_tasks = None Text
    , tags = None Text
    , import_role = None Text
  }
    }

in  [
    Item::{
      name = Some "Make sure docker is upgraded if requested",
      when = Some "docker_upgrade | bool",
      dpkg_selections = Some { name = "{{ item }}", selection = "install" },
      loop = Some [ "docker.io", "containerd" ]
    }
  , Item::{
      name = Some "Install/upgrade docker",
      apt = Some {
        name = [ "docker.io", "containerd" ]
      , state = "{{ \"latest\" if docker_upgrade | bool else \"present\" }}"
      , update_cache = True
    }
    }
  , Item::{
      name = Some "Make sure docker isn't upgraded",
      dpkg_selections = Some {
        name = "{{ item }}"
      , selection = "{{ 'hold' if docker_prevent_upgrade else 'install' }}"
    },
      loop = Some [ "docker.io", "containerd" ]
    }
  , Item::{ name = Some "Install docker-compose", pip = Some { name = "docker-compose" } }
  , Item::{
      name = Some "Install docker configuration",
      copy = Some { src = "daemon.json", dest = "/etc/docker/" },
      notify = Some "reload docker"
    }
  , Item::{
      name = Some "Start docker",
      systemd = Some { name = "docker", state = "started", enabled = True }
    }
  , Item::{
      when = Some "docker_periodic_cleanup",
      import_tasks = Some "cleanup.yml",
      tags = Some "docker_cleanup"
    }
  , Item::{ tags = Some "docker_utils", import_role = Some "name=icos.docker_utils" }
]
