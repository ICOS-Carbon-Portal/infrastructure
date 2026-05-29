-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some [ "vars[item] is undefined" ],
      loop = Some [ "nginxauth_users", "nginxauth_name" ]
    }
  , Task::{
      name = Some "Install apache2-utils",
      apt = Some {
        name = Some [ "apache2-utils" ]
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
      name = Some "Create directory for auth file",
      file = Some {
        path = Some "{{ nginxauth_file | dirname }}"
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
      name = Some "Add basic auth users",
      htpasswd = Some {
        path = "{{ nginxauth_file }}"
      , name = "{{ item.username }}"
      , password = "{{ item.password }}"
      , crypt_scheme = None Text
      , state = None Text
    },
      loop = Some [ "{{ nginxauth_users }}" ]
    }
]
