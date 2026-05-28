-- Auto-generated from scripts.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text })
    , copy : Optional ({ mode : Text, dest : Text, content : Text })
    , template : Optional ({ src : Text, dest : Text, mode : Text })
    , loop : Optional (List Text)
  }
    , default =
        { file = None ({ path : Text, state : Text })
    , copy = None ({ mode : Text, dest : Text, content : Text })
    , template = None ({ src : Text, dest : Text, mode : Text })
    , loop = None (List Text)
  }
    }

in  [
    Task::{
      name = "Create bin directory",
      file = Some { path = "{{ bbclient_bin_dir }}", state = "directory" }
    }
  , Task::{
      name = "Install borg wrapper that contains our ssh info",
      copy = Some {
        mode = "+x"
      , dest = "{{ bbclient_wrapper }}"
      , content = ''
        #!/bin/bash
        export BORG_RSH="{{ bbclient_ssh_bin }}"
        export BORG_BASE_DIR="{{ bbclient_borg_dir }}"
        exec {{ borg_bin }} "$@"

      ''
    }
    }
  , Task::{
      name = "Create helper scripts",
      template = Some { src = "{{ item }}", dest = "{{ bbclient_bin_dir }}", mode = "+x" },
      loop = Some [ "bbclient", "bbclient-all" ]
    }
]
