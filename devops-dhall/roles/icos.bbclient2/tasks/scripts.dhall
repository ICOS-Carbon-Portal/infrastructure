-- Auto-generated from scripts.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create bin directory",
      file = Some {
        path = Some "{{ bbclient_bin_dir }}"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Install borg wrapper that contains our ssh info",
      copy = Some {
        src = None Text
      , dest = "{{ bbclient_wrapper }}"
      , mode = Some "+x"
      , content = Some ''
        #!/bin/bash
        export BORG_RSH="{{ bbclient_ssh_bin }}"
        export BORG_BASE_DIR="{{ bbclient_borg_dir }}"
        exec {{ borg_bin }} "$@"

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Create helper scripts",
      template = Some {
        src = "{{ item }}"
      , dest = "{{ bbclient_bin_dir }}"
      , mode = Some "+x"
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      loop = Some [ "bbclient", "bbclient-all" ]
    }
]
