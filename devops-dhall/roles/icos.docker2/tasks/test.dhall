-- Auto-generated from ../../../../devops/roles/icos.docker2/tasks/test.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Test that docker can pull and execute images",
      shell = Some ''
      docker run --rm alpine apk | grep -q coffee

    '',
      register = Some "_apk",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
  , Task::{
      name = Some "Report docker status",
      debug = Some (Task.Poly_debug.Record {
          msg = ''
          Successfully ran an alpine image in {{ _apk.delta }}. It should take
          1-10 seconds, depending on whether the alpine image exists locally or
          not

        ''
      })
    }
]
