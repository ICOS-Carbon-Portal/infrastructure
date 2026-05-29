-- Auto-generated from ../../../../devops/roles/icos.stiltweb/tasks/utils.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Synchronize stilt-utils source",
      `ansible.posix.synchronize` = Some {
        mode = None Text,
        copy_links = None Bool,
        src = "stilt-utils",
        dest = "{{ stiltweb_home }}/",
        rsync_opts = Some [ "-F", "--delete-excluded" ],
        owner = Some False,
        group = Some False,
        perms = None Bool,
        delete = Some True
    },
      register = Some "_rsync"
    }
  , Task::{
      name = Some "Install stilt-utils",
      become = Some (Task.Poly_become.Bool True),
      become_user = Some "{{ stiltweb_username }}",
      `community.general.pipx` = Some {
        name = "{{ stiltweb_home }}/stilt-utils",
        executable = "pipx",
        python = Some "python3.12",
        editable = Some True,
        force = Some "{{ _rsync.changed }}"
    },
      register = Some "_pipx",
      changed_when = Some (Task.Poly_changed_when.Texts [
          "_pipx.changed"
        , "_pipx.stdout"
        , "_pipx.stdout.find('already seems to be installed') == -1"
      ]),
      environment = Some {
        BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = None Text,
        BORG_RELOCATED_REPO_ACCESS_IS_OK = None Text,
        PIPX_BIN_DIR = Some "{{ stiltweb_bindir }}",
        GOPATH = None Text
    }
    }
  , Task::{
      name = Some "Install scripts",
      template = Some {
        src = "{{ item }}",
        dest = "{{ stiltweb_bindir }}/",
        mode = Some "493",
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = Some "{{ stiltweb_username }}",
        group = Some "{{ stiltweb_username }}"
    },
      with_items = Some (Task.Poly_with_items.Texts [ "tail-latest.sh", "sync-station-names.sh", "sync-fsicos1-to-fsicos2.sh" ])
    }
]
