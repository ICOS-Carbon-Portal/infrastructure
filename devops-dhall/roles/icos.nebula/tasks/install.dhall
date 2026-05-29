-- Auto-generated from ../../../../devops/roles/icos.nebula/tasks/install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install packages",
      apt = Some {
        name = Some [ "jq" ],
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
      name = Some "Create nebula user",
      user = Some {
        name = "{{ nebula_user }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = Some "False",
        shell = Some "/usr/sbin/nologin",
        home = None Text,
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
      name = Some "Create etc directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ nebula_etc_dir }}",
          state = Some "directory",
          owner = Some "{{ nebula_user }}",
          group = Some "{{ nebula_user }}",
          name = None Text,
          mode = Some "448",
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Check whether nebula is already installed",
      stat = Some { path = "{{ nebula_bin_dir }}/nebula" },
      register = Some "_r"
    }
  , Task::{
      name = Some "Download and unpack nebula",
      include_tasks = Some (Task.Poly_include_tasks.Str "download.yml"),
      when = Some [ "not _r.stat.exists or nebula_upgrade" ]
    }
  , Task::{
      name = Some "Check that nebula runs",
      shell = Some ''
      {{ nebula_bin_dir }}/{{ item }} -version

    '',
      changed_when = Some (Task.Poly_changed_when.Bool False),
      register = Some "version",
      loop = Some (Task.Poly_loop.Texts [ "nebula", "nebula-cert" ])
    }
  , Task::{
      name = Some "Inform about installed version",
      run_once = Some True,
      debug = Some (Task.Poly_debug.Record {
          msg = ''
          We've installed nebula {{ version.results[0].stdout_lines[0] }}

        ''
      }),
      when = Some [ "not ansible_check_mode" ]
    }
]
