-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , pip : Optional ({ name : Text, virtualenv : Text, state : Text })
    , copy : Optional ({ dest : Text, mode : Text, content : Text })
  }
    , default =
        { pip = None ({ name : Text, virtualenv : Text, state : Text })
    , copy = None ({ dest : Text, mode : Text, content : Text })
  }
    }

in  [
    Task::{
      name = "Install pipx",
      pip = Some {
        name = "pipx"
      , virtualenv = "{{ pipx_home }}/.venv"
      , state = "{{ 'latest' if pipx_upgrade else 'present' }}"
    }
    }
  , Task::{
      name = "Create pipx cli wrapper",
      copy = Some {
        dest = "/usr/local/bin/pipx"
      , mode = "+x"
      , content = ''
        #!/usr/bin/bash
        {{ pipx_home }}/.venv/bin/pipx "$@"

      ''
    }
    }
  , Task::{
      name = "Create \"global\" version of pipx cli wrapper",
      copy = Some {
        dest = "/usr/local/sbin/pipx-global"
      , mode = "+x"
      , content = ''
        #!/usr/bin/bash
        PIPX_HOME={{ pipx_home }} PIPX_BIN_DIR=/usr/local/bin {{ pipx_home }}/.venv/bin/pipx "$@"

      ''
    }
    }
]
