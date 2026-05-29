-- Auto-generated from ../../../../devops/roles/icos.quince/tasks/quince-system.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create quince user",
      user = Some {
        name = "{{ quince_user }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = Some "/bin/bash",
        home = Some "{{ quince_home | default(omit) }}",
        password_lock = None Bool,
        groups = None ((List Text)),
        append = None Text,
        state = None Text,
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = None Text
    }
    }
  , Task::{
      name = Some "Create quince filestore directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ quince_filestore }}",
          state = Some "directory",
          owner = Some "{{ quince_user }}",
          group = Some "{{ quince_user }}",
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Install packages",
      apt = Some {
        name = Some [ "{{ item }}" ],
        state = None Text,
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    },
      loop = Some (Task.Poly_loop.Texts [ "mysql-server", "openjdk-{{ quince_jdk_version }}-jdk" ])
    }
]
