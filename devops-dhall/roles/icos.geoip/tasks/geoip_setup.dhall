-- Auto-generated from geoip_setup.yml

let Entry =
    { Type =
        { name : Text
    , user : Optional ({ name : Text, state : Text, create_home : Bool, home : Text })
    , register : Optional Text
    , file : Optional ({ path : Text, state : Text, owner : Optional Text, group : Optional Text })
    , template : Optional ({ src : Text, dest : Text })
    , with_items : Optional (List ({ src : Text, dest : Text }))
  }
    , default =
        { user = None ({ name : Text, state : Text, create_home : Bool, home : Text })
    , register = None Text
    , file = None ({ path : Text, state : Text, owner : Optional Text, group : Optional Text })
    , template = None ({ src : Text, dest : Text })
    , with_items = None (List ({ src : Text, dest : Text }))
  }
    }

in  [
    Entry::{
      name = "Create geoip user",
      user = Some {
        name = "{{ geoip_user }}"
      , state = "present"
      , create_home = False
      , home = "{{ geoip_home }}"
    },
      register = Some "_user"
    }
  , Entry::{
      name = "Create build directory",
      file = Some {
        path = "{{ geoip_build_dir }}"
      , state = "directory"
      , owner = None Text
      , group = None Text
    }
    }
  , Entry::{
      name = "Create database volume directory",
      file = Some {
        path = "{{ geoip_db_dir }}"
      , state = "directory"
      , owner = Some "{{ _user.uid }}"
      , group = Some "{{ _user.group }}"
    }
    }
  , Entry::{
      name = "Install files",
      template = Some { src = "{{ item.src }}", dest = "{{ item.dest }}" },
      with_items = Some [
        { src = "README.md", dest = "{{ geoip_home }}/README.md" }
      , { src = "Makefile", dest = "{{ geoip_home }}/Makefile" }
      , { src = "Dockerfile", dest = "{{ geoip_build_dir }}/Dockerfile" }
      , { src = "docker-compose.yml", dest = "{{ geoip_home }}/docker-compose.yml" }
    ]
    }
]
