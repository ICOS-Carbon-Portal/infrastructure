-- Auto-generated from setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create stiltweb user",
      user = Some {
        name = "{{ stiltweb_username }}"
      , home = Some "{{ stiltweb_home }}"
      , create_home = None Text
      , shell = Some "/bin/bash"
      , groups = Some [ "docker" ]
      , append = Some "True"
      , state = Some "present"
      , system = None Bool
      , password = None Text
      , generate_ssh_key = None Bool
      , remove = None Text
    }
    }
  , Task::{
      name = Some "Create directories",
      file = Some {
        path = Some "{{ item }}"
      , state = Some "directory"
      , mode = None Text
      , owner = Some "{{ stiltweb_username }}"
      , group = Some "{{ stiltweb_username }}"
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    },
      with_items = Some [ "{{ stiltweb_statedir }}", "{{ stiltweb_bindir }}" ]
    }
  , Task::{
      name = Some "Install netcdf C library",
      `ansible.builtin.package` = Some { name = "netcdf-bin", state = "present" }
    }
  , Task::{
      name = Some "Install jre",
      apt = Some {
        name = Some [ "{{ stiltweb_jre_package }}" ]
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
]
