-- Auto-generated from ../../../../devops/roles/icos.cpmeta/tasks/setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create cpmeta user",
      user = Some {
        name = "{{ cpmeta_user }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = Some "/bin/bash",
        home = Some "{{ cpmeta_home }}",
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
      name = Some "Copy SSL certs and private key for Handle.net client",
      copy = Some {
        dest = "{{ cpmeta_home }}/",
        mode = None Text,
        content = None Text,
        src = Some "ssl",
        backup = None Bool,
        owner = Some "{{ cpmeta_user }}",
        group = Some "{{ cpmeta_user }}",
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Create metaAppStorage directory (if not present), take ownership",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ cpmeta_filestorage_target }}",
          state = Some "directory",
          owner = Some "{{ cpmeta_user }}",
          group = Some "{{ cpmeta_user }}",
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = Some True,
          src = None Text
      })
    }
  , Task::{
      name = Some "Create rdfStorage directory (if not present), take ownership",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ cpmeta_rdfstorage_path }}",
          state = Some "directory",
          owner = Some "{{ cpmeta_user }}",
          group = Some "{{ cpmeta_user }}",
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = Some True,
          src = None Text
      })
    }
  , Task::{
      name = Some "Add systemd service",
      template = Some {
        src = "cpmeta.service",
        dest = "/etc/systemd/system/cpmeta.service",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      register = Some "_service"
    }
  , Task::{
      name = Some "Restart systemd service daemon",
      systemd = Some {
        name = Some "cpmeta.service",
        state = None Text,
        daemon_reload = None Bool,
        enabled = Some "True",
        `daemon-reload` = Some "True",
        status = None Text
    },
      when = Some [ "_service.changed" ]
    }
]
