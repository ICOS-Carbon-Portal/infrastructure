-- Auto-generated from ../../../../devops/roles/icos.restic_server/tasks/setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create restic_server directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ restic_server_exec | dirname }}",
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
      name = Some "Create restic user",
      user = Some {
        name = "{{ restic_server_user }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = Some "/usr/sbin/nologin",
        home = Some "{{ restic_server_data }}",
        password_lock = None Bool,
        groups = None ((List Text)),
        append = None Text,
        state = None Text,
        system = Some True,
        generate_ssh_key = None Bool,
        remove = None Text
    }
    }
  , Task::{
      name = Some "Create restic data directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ restic_server_data }}",
          state = Some "directory",
          owner = Some "{{ restic_server_user }}",
          group = Some "{{ restic_server_user }}",
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
]
