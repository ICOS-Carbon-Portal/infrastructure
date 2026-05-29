-- Auto-generated from ../../../../devops/roles/icos.doi/tasks/setup.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create doi user",
      user = Some {
        name = "{{ doi_user }}",
        uid = None Text,
        group = None Text,
        password = None Text,
        non_unique = None Bool,
        create_home = None Text,
        shell = Some "/bin/bash",
        home = Some "{{ doi_home }}",
        password_lock = None Bool,
        groups = None ((List Text)),
        append = None Text,
        state = None Text,
        system = None Bool,
        generate_ssh_key = None Bool,
        remove = None Text
    }
    }
]
