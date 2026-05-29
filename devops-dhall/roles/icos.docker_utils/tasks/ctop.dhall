-- Auto-generated from ../../../../devops/roles/icos.docker_utils/tasks/ctop.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove /usr/local/sbin/ctop",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "absent",
          owner = None Text,
          group = None Text,
          name = Some "/usr/local/sbin/ctop",
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
]
