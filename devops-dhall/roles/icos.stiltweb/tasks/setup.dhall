-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , user : Optional ({ name : Text, state : Text, shell : Text, home : Text, groups : Text, append : Bool })
    , file : Optional ({ path : Text, state : Text, owner : Text, group : Text })
    , with_items : Optional (List Text)
    , `ansible.builtin.package` : Optional ({ name : Text, state : Text })
    , apt : Optional ({ name : Text })
  }
    , default =
        { user = None ({ name : Text, state : Text, shell : Text, home : Text, groups : Text, append : Bool })
    , file = None ({ path : Text, state : Text, owner : Text, group : Text })
    , with_items = None (List Text)
    , `ansible.builtin.package` = None ({ name : Text, state : Text })
    , apt = None ({ name : Text })
  }
    }

in  [
    Task::{
      name = "Create stiltweb user",
      user = Some {
        name = "{{ stiltweb_username }}"
      , state = "present"
      , shell = "/bin/bash"
      , home = "{{ stiltweb_home }}"
      , groups = "docker"
      , append = True
    }
    }
  , Task::{
      name = "Create directories",
      file = Some {
        path = "{{ item }}"
      , state = "directory"
      , owner = "{{ stiltweb_username }}"
      , group = "{{ stiltweb_username }}"
    },
      with_items = Some [ "{{ stiltweb_statedir }}", "{{ stiltweb_bindir }}" ]
    }
  , Task::{
      name = "Install netcdf C library",
      `ansible.builtin.package` = Some { name = "netcdf-bin", state = "present" }
    }
  , Task::{ name = "Install jre", apt = Some { name = "{{ stiltweb_jre_package }}" } }
]
