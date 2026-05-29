-- Auto-generated from ../../../../devops/roles/icos.nebula/tasks/ca.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy Certificate Authority",
      copy = Some {
        dest = "{{ nebula_etc_dir }}/ca.crt",
        mode = None Text,
        content = None Text,
        src = Some "{{ nebula_cert_copy }}",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      notify = Some [ "reload nebula" ]
    }
]
