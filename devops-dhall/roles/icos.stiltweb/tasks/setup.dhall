-- Auto-generated from ../../../../devops/roles/icos.stiltweb/tasks/setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create stiltweb user",
      user = Some {
        name = "{{ stiltweb_username }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = Some "/bin/bash",
        home = Some "{{ stiltweb_home }}",
        password_lock = None Bool,
        groups = Some [ "docker" ],
        append = Some "True",
        state = Some "present",
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = None Text
    }
    }
  , Task::{
      name = Some "Create directories",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ item }}",
          state = Some "directory",
          owner = Some "{{ stiltweb_username }}",
          group = Some "{{ stiltweb_username }}",
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      with_items = Some (Task.Poly_with_items.Texts [ "{{ stiltweb_statedir }}", "{{ stiltweb_bindir }}" ])
    }
  , Task::{
      name = Some "Install netcdf C library",
      `ansible.builtin.package` = Some { name = "netcdf-bin", state = "present" }
    }
  , Task::{
      name = Some "Install jre",
      apt = Some {
        name = Some [ "{{ stiltweb_jre_package }}" ],
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
]
