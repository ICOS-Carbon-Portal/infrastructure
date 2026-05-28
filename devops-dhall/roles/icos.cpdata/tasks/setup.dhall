-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : Text })
    , user : Optional ({ name : Text, home : Text, shell : Text })
    , file : Optional ({ path : Text, state : Text, owner : Text, group : Text })
    , copy : Optional ({ src : Text, dest : Text })
  }
    , default =
        { apt = None ({ name : Text })
    , user = None ({ name : Text, home : Text, shell : Text })
    , file = None ({ path : Text, state : Text, owner : Text, group : Text })
    , copy = None ({ src : Text, dest : Text })
  }
    }

in  [
    Task::{ name = "Install jre", apt = Some { name = "{{ cpdata_jre_package }}" } }
  , Task::{
      name = "Create cpdata user",
      user = Some { name = "{{ cpdata_user }}", home = "{{ cpdata_home }}", shell = "/bin/bash" }
    }
  , Task::{
      name = "Create dataAppStorage directory (if not present), take ownership",
      file = Some {
        path = "{{ cpdata_filestorage_target }}"
      , state = "directory"
      , owner = "{{ cpdata_user }}"
      , group = "{{ cpdata_user }}"
    }
    }
  , Task::{
      name = "Set up logrotate for ETC facade",
      copy = Some { src = "etc-facade", dest = "/etc/logrotate.d/etc-facade" }
    }
]
