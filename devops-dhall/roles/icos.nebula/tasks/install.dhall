-- Auto-generated from install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install packages",
      apt = Some {
        name = Some [ "jq" ]
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
      name = Some "Create nebula user",
      user = Some {
        name = "{{ nebula_user }}"
      , home = None Text
      , create_home = Some "False"
      , shell = Some "/usr/sbin/nologin"
      , groups = None (List Text)
      , append = None Text
      , state = None Text
      , system = Some True
      , password = None Text
      , generate_ssh_key = None Bool
      , remove = None Text
    }
    }
  , Task::{
      name = Some "Create etc directory",
      file = Some {
        path = Some "{{ nebula_etc_dir }}"
      , state = Some "directory"
      , mode = Some "448"
      , owner = Some "{{ nebula_user }}"
      , group = Some "{{ nebula_user }}"
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Check whether nebula is already installed",
      stat = Some { path = "{{ nebula_bin_dir }}/nebula" },
      register = Some "_r"
    }
  , Task::{
      name = Some "Download and unpack nebula",
      include_tasks = Some "download.yml",
      when = Some [ "not _r.stat.exists or nebula_upgrade" ]
    }
  , Task::{
      name = Some "Check that nebula runs",
      shell = Some ''
      {{ nebula_bin_dir }}/{{ item }} -version

    '',
      changed_when = Some "False",
      register = Some "version",
      loop = Some [ "nebula", "nebula-cert" ]
    }
  , Task::{
      name = Some "Inform about installed version",
      run_once = Some True,
      debug = Some {
        msg = ''
        We've installed nebula {{ version.results[0].stdout_lines[0] }}

      ''
    },
      when = Some [ "not ansible_check_mode" ]
    }
]
