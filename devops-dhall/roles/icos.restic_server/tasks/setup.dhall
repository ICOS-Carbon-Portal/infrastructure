-- Auto-generated from setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create restic_server directory",
      file = Some {
        path = Some "{{ restic_server_exec | dirname }}"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Create restic user",
      user = Some {
        name = "{{ restic_server_user }}"
      , home = Some "{{ restic_server_data }}"
      , create_home = None Text
      , shell = Some "/usr/sbin/nologin"
      , groups = None (List Text)
      , append = None Text
      , state = None Text
      , system = Some True
      , password = None Text
      , generate_ssh_key = None Bool
      , remove = None Text
    }
    }
  , Task::{
      name = Some "Create restic data directory",
      file = Some {
        path = Some "{{ restic_server_data }}"
      , state = Some "directory"
      , mode = None Text
      , owner = Some "{{ restic_server_user }}"
      , group = Some "{{ restic_server_user }}"
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Install the passlib library",
      apt = Some {
        name = Some [ "python3-passlib" ]
      , state = None Text
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Install apache2-utils",
      apt = Some {
        name = Some [ "apache2-utils" ]
      , state = Some "present"
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
]
