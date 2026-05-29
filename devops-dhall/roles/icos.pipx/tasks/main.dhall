-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install pipx",
      pip = Some {
        name = [ "pipx" ]
      , virtualenv = Some "{{ pipx_home }}/.venv"
      , state = Some "{{ 'latest' if pipx_upgrade else 'present' }}"
    }
    }
  , Task::{
      name = Some "Create pipx cli wrapper",
      copy = Some {
        src = None Text
      , dest = "/usr/local/bin/pipx"
      , mode = Some "+x"
      , content = Some ''
        #!/usr/bin/bash
        {{ pipx_home }}/.venv/bin/pipx "$@"

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Create \"global\" version of pipx cli wrapper",
      copy = Some {
        src = None Text
      , dest = "/usr/local/sbin/pipx-global"
      , mode = Some "+x"
      , content = Some ''
        #!/usr/bin/bash
        PIPX_HOME={{ pipx_home }} PIPX_BIN_DIR=/usr/local/bin {{ pipx_home }}/.venv/bin/pipx "$@"

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
]
