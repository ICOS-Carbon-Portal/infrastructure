-- Auto-generated from ../../../../devops/roles/icos.nginxauth/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check that all parameters are defined",
      fail = Some { msg = "{{ item }} needs to be defined" },
      when = Some [ "vars[item] is undefined" ],
      loop = Some (Task.Poly_loop.Texts [ "nginxauth_users", "nginxauth_name" ])
    }
  , Task::{
      name = Some "Install apache2-utils",
      apt = Some {
        name = Some [ "apache2-utils" ],
        state = None Text,
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Install the passlib library",
      apt = Some {
        name = Some [ "python3-passlib" ],
        state = None Text,
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Create directory for auth file",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ nginxauth_file | dirname }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Add basic auth users",
      htpasswd = Some {
        path = "{{ nginxauth_file }}",
        name = "{{ item.username }}",
        password = "{{ item.password }}",
        crypt_scheme = None Text,
        state = None Text
    },
      loop = Some (Task.Poly_loop.Str "{{ nginxauth_users }}")
    }
]
