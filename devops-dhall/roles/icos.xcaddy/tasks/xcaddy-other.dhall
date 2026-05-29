-- Auto-generated from ../../../../devops/roles/icos.xcaddy/tasks/xcaddy-other.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install xcaddy",
      command = Some "go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest",
      args = Some {
        chdir = None Text,
        creates = Some "{{ omit if xcaddy_upgrade else '/opt/xcaddy' }}",
        executable = None Text,
        removes = None Text
    },
      environment = Some {
        BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = None Text,
        BORG_RELOCATED_REPO_ACCESS_IS_OK = None Text,
        PIPX_BIN_DIR = None Text,
        GOPATH = Some "/opt/xcaddy"
    }
    }
  , Task::{
      name = Some "Create /usr/local/bin/xcaddy symlink",
      file = Some (Task.Poly_file.Record {
          path = None Text,
          state = Some "link",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = Some "/usr/local/bin/xcaddy",
          recurse = None Bool,
          src = Some "/opt/xcaddy/bin/xcaddy"
      })
    }
]
