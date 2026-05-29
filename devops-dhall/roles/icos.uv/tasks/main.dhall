-- Auto-generated from ../../../../devops/roles/icos.uv/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Check whether uv is installed",
      stat = Some { path = "/usr/local/bin/uv" },
      register = Some "_r"
    }
  , Task::{
      name = Some "Install/upgrade uv",
      include_tasks = Some (Task.Poly_include_tasks.Record { file = "install.yml", apply = None (({ tags : Text })) }),
      when = Some [ "not _r.stat.exists or uv_upgrade or not ansible_check_mode" ]
    }
  , Task::{
      name = Some "Create \"global\" version of uv",
      copy = Some {
        dest = "/usr/local/sbin/uv-global",
        mode = Some "+x",
        content = Some ''
        #!/usr/bin/bash
        # This wrapper installs globally available tools using "uv tool"
        export UV_TOOL_DIR={{ uv_home }}/tools
        export UV_TOOL_BIN_DIR=/usr/local/bin
        export UV_CACHE_DIR={{ uv_home }}/cache
        export UV_PYTHON_INSTALL_DIR={{ uv_home }}/python
        exec /usr/local/bin/uv "$@"

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
]
