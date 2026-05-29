-- Auto-generated from flexpart_ssh.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install local flexpart script",
      copy = Some {
        src = None Text
      , dest = "/usr/local/bin/flexpart"
      , mode = Some "493"
      , content = Some ''
        #/usr/bin/bash
        exec ssh -q flexpart "$@"

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Install local start-all-flexpart script",
      copy = Some {
        src = Some "start-all-flexpart.sh"
      , dest = "/usr/local/bin/start-all-flexpart"
      , mode = Some "493"
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      include_tasks = Some "flexpart_ssh_user.yml",
      loop = Some [ "{{ flexpart_ssh_users }}" ],
      loop_control = Some { loop_var = Some "_ssh_user", label = None Text }
    }
]
