-- Auto-generated from ../../../../devops/roles/icos.flexextract/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create flexextract user",
      user = Some {
        name = "{{ flexextract_user }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = Some "/bin/bash",
        home = Some "{{ flexextract_home | default(omit) }}",
        password_lock = None Bool,
        groups = Some [ "docker" ],
        append = Some "True",
        state = None Text,
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = None Text
    }
    }
  , Task::{
      name = Some "Add passwordless sudo for flexextract",
      copy = Some {
        dest = "/etc/sudoers.d/flexextract",
        mode = None Text,
        content = Some ''
        flexextract ALL = NOPASSWD: ALL

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      import_tasks = Some "flexextract.yml",
      become = Some (Task.Poly_become.Bool True),
      become_user = Some "flexextract"
    }
]
