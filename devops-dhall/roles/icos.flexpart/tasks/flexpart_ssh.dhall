-- Auto-generated from flexpart_ssh.yml

let Item =
    { Type =
        { name : Optional Text
    , copy : Optional ({ dest : Text, mode : Natural, content : Optional Text, src : Optional Text })
    , include_tasks : Optional Text
    , loop : Optional Text
    , loop_control : Optional ({ loop_var : Text })
  }
    , default =
        { name = None Text
    , copy = None ({ dest : Text, mode : Natural, content : Optional Text, src : Optional Text })
    , include_tasks = None Text
    , loop = None Text
    , loop_control = None ({ loop_var : Text })
  }
    }

in  [
    Item::{
      name = Some "Install local flexpart script",
      copy = Some {
        dest = "/usr/local/bin/flexpart"
      , mode = 493
      , content = Some ''
        #/usr/bin/bash
        exec ssh -q flexpart "$@"

      ''
      , src = None Text
    }
    }
  , Item::{
      name = Some "Install local start-all-flexpart script",
      copy = Some {
        dest = "/usr/local/bin/start-all-flexpart"
      , mode = 493
      , content = None Text
      , src = Some "start-all-flexpart.sh"
    }
    }
  , Item::{
      include_tasks = Some "flexpart_ssh_user.yml",
      loop = Some "{{ flexpart_ssh_users }}",
      loop_control = Some { loop_var = "_ssh_user" }
    }
]
