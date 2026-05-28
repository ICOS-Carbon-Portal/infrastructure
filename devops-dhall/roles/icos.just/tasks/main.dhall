-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , stat : Optional ({ path : Text })
    , register : Optional Text
    , include_tasks : Optional ({ file : Text })
    , when : Optional Text
    , file : Optional ({ path : Text, state : Text })
    , `ansible.builtin.shell` : Optional Text
    , args : Optional ({ creates : Text, executable : Text })
  }
    , default =
        { stat = None ({ path : Text })
    , register = None Text
    , include_tasks = None ({ file : Text })
    , when = None Text
    , file = None ({ path : Text, state : Text })
    , `ansible.builtin.shell` = None Text
    , args = None ({ creates : Text, executable : Text })
  }
    }

in  [
    Entry::{
      name = "Check whether just is installed",
      stat = Some { path = "/usr/local/bin/just" },
      register = Some "_r"
    }
  , Entry::{
      name = "Install/upgrade just",
      include_tasks = Some { file = "install.yml" },
      when = Some "not _r.stat.exists or just_upgrade"
    }
  , Entry::{
      name = "Create bash_completion.d directory",
      file = Some { path = "/etc/bash_completion.d", state = "directory" }
    }
  , Entry::{
      name = "Add bash completions for just",
      `ansible.builtin.shell` = Some ''
      just --completions bash > /etc/bash_completion.d/just

    '',
      args = Some { creates = "/etc/bash_completion.d/just", executable = "/bin/bash" }
    }
]
