-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , stat : Optional ({ path : Text })
    , register : Optional Text
    , include_tasks : Optional ({ file : Text })
    , when : Optional Text
    , copy : Optional ({ dest : Text, mode : Text, content : Text })
  }
    , default =
        { stat = None ({ path : Text })
    , register = None Text
    , include_tasks = None ({ file : Text })
    , when = None Text
    , copy = None ({ dest : Text, mode : Text, content : Text })
  }
    }

in  [
    Task::{
      name = "Check whether uv is installed",
      stat = Some { path = "/usr/local/bin/uv" },
      register = Some "_r"
    }
  , Task::{
      name = "Install/upgrade uv",
      include_tasks = Some { file = "install.yml" },
      when = Some "not _r.stat.exists or uv_upgrade or not ansible_check_mode"
    }
  , Task::{
      name = "Create \"global\" version of uv",
      copy = Some {
        dest = "/usr/local/sbin/uv-global"
      , mode = "+x"
      , content = ''
        #!/usr/bin/bash
        # This wrapper installs globally available tools using "uv tool"
        export UV_TOOL_DIR={{ uv_home }}/tools
        export UV_TOOL_BIN_DIR=/usr/local/bin
        export UV_CACHE_DIR={{ uv_home }}/cache
        export UV_PYTHON_INSTALL_DIR={{ uv_home }}/python
        exec /usr/local/bin/uv "$@"

      ''
    }
    }
]
