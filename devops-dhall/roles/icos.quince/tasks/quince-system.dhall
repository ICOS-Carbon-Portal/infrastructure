-- Auto-generated from quince-system.yml

let Task =
    { Type =
        { name : Text
    , user : Optional ({ name : Text, home : Text, shell : Text })
    , file : Optional ({ path : Text, state : Text, owner : Text, group : Text })
    , apt : Optional ({ name : Text })
    , loop : Optional (List Text)
  }
    , default =
        { user = None ({ name : Text, home : Text, shell : Text })
    , file = None ({ path : Text, state : Text, owner : Text, group : Text })
    , apt = None ({ name : Text })
    , loop = None (List Text)
  }
    }

in  [
    Task::{
      name = "Create quince user",
      user = Some {
        name = "{{ quince_user }}"
      , home = "{{ quince_home | default(omit) }}"
      , shell = "/bin/bash"
    }
    }
  , Task::{
      name = "Create quince filestore directory",
      file = Some {
        path = "{{ quince_filestore }}"
      , state = "directory"
      , owner = "{{ quince_user }}"
      , group = "{{ quince_user }}"
    }
    }
  , Task::{
      name = "Install packages",
      apt = Some { name = "{{ item }}" },
      loop = Some [ "mysql-server", "openjdk-{{ quince_jdk_version }}-jdk" ]
    }
]
