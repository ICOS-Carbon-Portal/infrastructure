-- Auto-generated from ../../../../devops/roles/icos.registry/tasks/auth.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create auth directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ registry_htpasswd_file | dirname }}",
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
        path = "{{ registry_htpasswd_file }}",
        name = "{{ item.name }}",
        password = "{{ item.password }}",
        crypt_scheme = Some "bcrypt",
        state = None Text
    },
      loop = Some (Task.Poly_loop.Str "{{ registry_users }}")
    }
]
