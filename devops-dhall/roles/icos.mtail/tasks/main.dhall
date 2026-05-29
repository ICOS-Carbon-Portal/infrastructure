-- Auto-generated from ../../../../devops/roles/icos.mtail/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install mtail",
      apt = Some {
        name = Some [ "mtail" ],
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
      name = Some "Configure mtail",
      lineinfile = Some {
        path = "/etc/default/mtail",
        regex = None Text,
        line = Some "{{ item.key }}={{ item.val }}",
        state = Some "present",
        backrefs = None Bool,
        regexp = Some "^#?{{ item.key }}=",
        create = Some False,
        owner = None Text,
        group = None Text,
        insertafter = None Text,
        mode = None Natural,
        insertbefore = None Text
    },
      loop = Some (Task.Poly_loop.Records [
          {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = Some "LOGS",
            val = Some "{{ mtail_logs | join(',') }}",
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = Some "PORT",
            val = Some "{{ mtail_port }}",
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
        , {
            question = None Text,
            value = None Text,
            vtype = None Text,
            s = None Text,
            f = None Text,
            param = None Text,
            append = None Bool,
            line = None Text,
            regex = None Text,
            src = None Text,
            dest = None Text,
            name = None Text,
            mode = None Text,
            key = Some "HOST",
            val = Some "{{ mtail_host }}",
            file = None Text,
            set_fact = None Text,
            file_var = None Text,
            content = None Text,
            port = None Text,
            path = None Text
        }
      ]),
      notify = Some [ "reload mtail" ]
    }
  , Task::{
      name = Some "Install configure icos programs",
      copy = Some {
        dest = "/etc/mtail",
        mode = None Text,
        content = None Text,
        src = Some "{{ item }}",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = Some "mtail --compile_only -port 0 --progs %s"
    },
      notify = Some [ "reload mtail" ],
      loop = Some (Task.Poly_loop.Str "{{ mtail_programs }}")
    }
  , Task::{
      name = Some "Find unconfigured icos programs",
      find = Some {
        paths = "/etc/mtail",
        patterns = "icos-*.mtail",
        excludes = Some "{{ mtail_programs }}",
        file_type = None Text,
        recurse = None Bool
    },
      register = Some "_find"
    }
  , Task::{
      name = Some "Remove unconfigured icos programs",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "{{ item }}",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      }),
      notify = Some [ "reload mtail" ],
      loop = Some (Task.Poly_loop.Str "{{ _find.files | map(attribute='path') }}")
    }
  , Task::{
      name = Some "Start mtail service",
      systemd = Some {
        name = Some "mtail",
        state = Some "started",
        daemon_reload = None Bool,
        enabled = Some "True",
        `daemon-reload` = None Text,
        status = None Text
    }
    }
  , Task::{
      name = Some "Check that the mtail http server is responding",
      uri = Some {
        url = "http://{{ mtail_host }}:{{ mtail_port }}",
        return_content = None Bool,
        method = None Text,
        user = None Text,
        password = None Text
    },
      retries = Some 10
    }
]
