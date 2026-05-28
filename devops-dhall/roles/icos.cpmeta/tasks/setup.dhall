-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , user : Optional ({ name : Text, home : Text, shell : Text })
    , copy : Optional ({ src : Text, dest : Text, owner : Text, group : Text })
    , file : Optional ({ path : Text, state : Text, owner : Text, group : Text, recurse : Bool })
    , template : Optional ({ src : Text, dest : Text })
    , register : Optional Text
    , systemd : Optional ({ name : Text, enabled : Bool, `daemon-reload` : Bool })
    , when : Optional Text
  }
    , default =
        { user = None ({ name : Text, home : Text, shell : Text })
    , copy = None ({ src : Text, dest : Text, owner : Text, group : Text })
    , file = None ({ path : Text, state : Text, owner : Text, group : Text, recurse : Bool })
    , template = None ({ src : Text, dest : Text })
    , register = None Text
    , systemd = None ({ name : Text, enabled : Bool, `daemon-reload` : Bool })
    , when = None Text
  }
    }

in  [
    Task::{
      name = "Create cpmeta user",
      user = Some { name = "{{ cpmeta_user }}", home = "{{ cpmeta_home }}", shell = "/bin/bash" }
    }
  , Task::{
      name = "Copy SSL certs and private key for Handle.net client",
      copy = Some {
        src = "ssl"
      , dest = "{{ cpmeta_home }}/"
      , owner = "{{ cpmeta_user }}"
      , group = "{{ cpmeta_user }}"
    }
    }
  , Task::{
      name = "Create metaAppStorage directory (if not present), take ownership",
      file = Some {
        path = "{{ cpmeta_filestorage_target }}"
      , state = "directory"
      , owner = "{{ cpmeta_user }}"
      , group = "{{ cpmeta_user }}"
      , recurse = True
    }
    }
  , Task::{
      name = "Create rdfStorage directory (if not present), take ownership",
      file = Some {
        path = "{{ cpmeta_rdfstorage_path }}"
      , state = "directory"
      , owner = "{{ cpmeta_user }}"
      , group = "{{ cpmeta_user }}"
      , recurse = True
    }
    }
  , Task::{
      name = "Add systemd service",
      template = Some { src = "cpmeta.service", dest = "/etc/systemd/system/cpmeta.service" },
      register = Some "_service"
    }
  , Task::{
      name = "Restart systemd service daemon",
      systemd = Some { name = "cpmeta.service", enabled = True, `daemon-reload` = True },
      when = Some "_service.changed"
    }
]
