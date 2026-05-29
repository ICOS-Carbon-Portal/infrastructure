-- Auto-generated from quince-system.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create quince user",
      user = Some {
        name = "{{ quince_user }}"
      , home = Some "{{ quince_home | default(omit) }}"
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
      name = Some "Create quince filestore directory",
      file = Some {
        path = Some "{{ quince_filestore }}"
      , state = Some "directory"
      , mode = None Text
      , owner = Some "{{ quince_user }}"
      , group = Some "{{ quince_user }}"
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Install packages",
      apt = Some {
        name = Some [ "{{ item }}" ]
      , state = None Text
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    },
      loop = Some [ "mysql-server", "openjdk-{{ quince_jdk_version }}-jdk" ]
    }
]
