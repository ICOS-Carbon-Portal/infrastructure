-- Auto-generated from ../../../../devops/roles/icos.postgresql/tasks/install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Adding the apt key for postgresql",
      apt_key = Some {
        id = Some "ACCC4CF8",
        url = "https://www.postgresql.org/media/keys/ACCC4CF8.asc",
        state = "present"
    }
    }
  , Task::{
      name = Some "Adding the postgresql repo",
      apt_repository = Some {
        filename = Some "pgdg",
        repo = "deb http://apt.postgresql.org/pub/repos/apt/ {{ansible_distribution_release}}-pgdg main"
    }
    }
  , Task::{
      name = Some "Install postgresql",
      apt = Some {
        name = Some [ "{{ 'postgresql-%s' % postgresql_version }}" ],
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
      name = Some "Install postgis",
      apt = Some {
        name = Some [ "{{ 'postgresql-%s-postgis-3' % postgresql_version }}" ],
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
      when = Some [ "postgresql_postgis_enable" ]
    }
  , Task::{
      name = Some "Install python3 psycopg2-binary library",
      pip = Some (Task.Poly_pip.Record { name = [ "psycopg2-binary" ], virtualenv = None Text, state = Some "present" })
    }
  , Task::{
      name = Some "Create {{ postgresql_bin }} directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ postgresql_bin }}",
          state = Some "directory",
          owner = Some "postgres",
          group = Some "postgres",
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Modify ~/.profile",
      lineinfile = Some {
        path = "{{ postgresql_home }}/.profile",
        regex = Some "^PATH=",
        line = Some "PATH=$HOME/bin:$PATH",
        state = Some "present",
        backrefs = None Bool,
        regexp = None Text,
        create = Some True,
        owner = Some "postgres",
        group = Some "postgres",
        insertafter = None Text,
        mode = None Natural,
        insertbefore = None Text
    }
    }
]
