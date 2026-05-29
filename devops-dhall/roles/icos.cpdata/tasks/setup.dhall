-- Auto-generated from setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install jre",
      apt = Some {
        name = Some [ "{{ cpdata_jre_package }}" ]
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
      name = Some "Create cpdata user",
      user = Some {
        name = "{{ cpdata_user }}"
      , home = Some "{{ cpdata_home }}"
      , create_home = None Text
      , shell = Some "/bin/bash"
      , groups = None (List Text)
      , append = None Text
      , state = None Text
      , system = None Bool
      , password = None Text
      , generate_ssh_key = None Bool
      , remove = None Text
    }
    }
  , Task::{
      name = Some "Create dataAppStorage directory (if not present), take ownership",
      file = Some {
        path = Some "{{ cpdata_filestorage_target }}"
      , state = Some "directory"
      , mode = None Text
      , owner = Some "{{ cpdata_user }}"
      , group = Some "{{ cpdata_user }}"
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Set up logrotate for ETC facade",
      copy = Some {
        src = Some "etc-facade"
      , dest = "/etc/logrotate.d/etc-facade"
      , mode = None Text
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
]
