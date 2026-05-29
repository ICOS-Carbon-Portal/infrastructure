-- Auto-generated from ../../../../devops/roles/icos.cpauth/tasks/setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create cpauth user",
      user = Some {
        name = "{{ cpauth_user }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = Some "/bin/bash",
        home = Some "{{ cpauth_home }}",
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
      name = Some "Copy keys",
      copy = Some {
        dest = "{{ cpauth_home }}",
        mode = None Text,
        content = None Text,
        src = Some "privateKeys",
        backup = None Bool,
        owner = Some "{{ cpauth_user }}",
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
]
