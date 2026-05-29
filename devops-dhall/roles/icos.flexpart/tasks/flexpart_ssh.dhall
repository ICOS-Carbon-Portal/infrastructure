-- Auto-generated from ../../../../devops/roles/icos.flexpart/tasks/flexpart_ssh.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install local flexpart script",
      copy = Some {
        dest = "/usr/local/bin/flexpart",
        mode = Some "493",
        content = Some ''
        #/usr/bin/bash
        exec ssh -q flexpart "$@"

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
      name = Some "Install local start-all-flexpart script",
      copy = Some {
        dest = "/usr/local/bin/start-all-flexpart",
        mode = Some "493",
        content = None Text,
        src = Some "start-all-flexpart.sh",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      include_tasks = Some (Task.Poly_include_tasks.Str "flexpart_ssh_user.yml"),
      loop = Some (Task.Poly_loop.Str "{{ flexpart_ssh_users }}"),
      loop_control = Some { loop_var = Some "_ssh_user", label = None Text }
    }
]
