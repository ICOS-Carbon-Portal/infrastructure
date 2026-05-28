-- Auto-generated from setup.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text, owner : Optional Text, group : Optional Text })
    , user : Optional ({ name : Text, home : Text, shell : Text, system : Bool })
    , apt : Optional ({ name : Text, state : Optional Text })
  }
    , default =
        { file = None ({ path : Text, state : Text, owner : Optional Text, group : Optional Text })
    , user = None ({ name : Text, home : Text, shell : Text, system : Bool })
    , apt = None ({ name : Text, state : Optional Text })
  }
    }

in  [
    Task::{
      name = "Create restic_server directory",
      file = Some {
        path = "{{ restic_server_exec | dirname }}"
      , state = "directory"
      , owner = None Text
      , group = None Text
    }
    }
  , Task::{
      name = "Create restic user",
      user = Some {
        name = "{{ restic_server_user }}"
      , home = "{{ restic_server_data }}"
      , shell = "/usr/sbin/nologin"
      , system = True
    }
    }
  , Task::{
      name = "Create restic data directory",
      file = Some {
        path = "{{ restic_server_data }}"
      , state = "directory"
      , owner = Some "{{ restic_server_user }}"
      , group = Some "{{ restic_server_user }}"
    }
    }
  , Task::{
      name = "Install the passlib library",
      apt = Some { name = "python3-passlib", state = None Text }
    }
  , Task::{
      name = "Install apache2-utils",
      apt = Some { name = "apache2-utils", state = Some "present" }
    }
]
