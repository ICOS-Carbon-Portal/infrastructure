-- Auto-generated from ../../../../devops/roles/icos.nginxforward/tasks/auth.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install apache2-utils",
      apt = Some {
        name = Some [ "apache2-utils" ],
        state = Some "present",
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
      name = Some "Add basic auth users",
      htpasswd = Some {
        path = "{{ nginxforward_user_file }}",
        name = "{{ item.name }}",
        password = "{{ item.password }}",
        crypt_scheme = None Text,
        state = None Text
    },
      loop = Some (Task.Poly_loop.Str "{{ nginxforward_users }}")
    }
]
