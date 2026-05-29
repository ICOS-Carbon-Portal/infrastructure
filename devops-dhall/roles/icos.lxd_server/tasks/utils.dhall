-- Auto-generated from ../../../../devops/roles/icos.lxd_server/tasks/utils.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy utilities",
      copy = Some {
        dest = "/usr/local/sbin/{{ item }}",
        mode = Some "493",
        content = None Text,
        src = Some "{{ item }}",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      loop = Some (Task.Poly_loop.Texts [ "lxdfs" ])
    }
]
