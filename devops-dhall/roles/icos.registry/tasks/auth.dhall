-- Auto-generated from auth.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create auth directory",
      file = Some {
        path = Some "{{ registry_htpasswd_file | dirname }}"
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
      name = Some "Add basic auth users",
      htpasswd = Some {
        path = "{{ registry_htpasswd_file }}"
      , name = "{{ item.name }}"
      , password = "{{ item.password }}"
      , crypt_scheme = Some "bcrypt"
      , state = None Text
    },
      loop = Some [ "{{ registry_users }}" ]
    }
]
