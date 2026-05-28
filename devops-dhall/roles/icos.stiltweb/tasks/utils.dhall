-- Auto-generated from utils.yml

let Entry =
    { Type =
        { name : Text
    , `ansible.posix.synchronize` : Optional ({ src : Text, dest : Text, delete : Bool, owner : Bool, group : Bool, rsync_opts : List Text })
    , register : Optional Text
    , become : Optional Bool
    , become_user : Optional Text
    , `community.general.pipx` : Optional ({ executable : Text, python : Text, editable : Bool, force : Text, name : Text })
    , changed_when : Optional (List Text)
    , environment : Optional ({ PIPX_BIN_DIR : Text })
    , template : Optional ({ src : Text, dest : Text, owner : Text, group : Text, mode : Natural })
    , with_items : Optional (List Text)
  }
    , default =
        { `ansible.posix.synchronize` = None ({ src : Text, dest : Text, delete : Bool, owner : Bool, group : Bool, rsync_opts : List Text })
    , register = None Text
    , become = None Bool
    , become_user = None Text
    , `community.general.pipx` = None ({ executable : Text, python : Text, editable : Bool, force : Text, name : Text })
    , changed_when = None (List Text)
    , environment = None ({ PIPX_BIN_DIR : Text })
    , template = None ({ src : Text, dest : Text, owner : Text, group : Text, mode : Natural })
    , with_items = None (List Text)
  }
    }

in  [
    Entry::{
      name = "Synchronize stilt-utils source",
      `ansible.posix.synchronize` = Some {
        src = "stilt-utils"
      , dest = "{{ stiltweb_home }}/"
      , delete = True
      , owner = False
      , group = False
      , rsync_opts = [ "-F", "--delete-excluded" ]
    },
      register = Some "_rsync"
    }
  , Entry::{
      name = "Install stilt-utils",
      register = Some "_pipx",
      become = Some True,
      become_user = Some "{{ stiltweb_username }}",
      `community.general.pipx` = Some {
        executable = "pipx"
      , python = "python3.12"
      , editable = True
      , force = "{{ _rsync.changed }}"
      , name = "{{ stiltweb_home }}/stilt-utils"
    },
      changed_when = Some [
        "_pipx.changed"
      , "_pipx.stdout"
      , "_pipx.stdout.find('already seems to be installed') == -1"
    ],
      environment = Some { PIPX_BIN_DIR = "{{ stiltweb_bindir }}" }
    }
  , Entry::{
      name = "Install scripts",
      template = Some {
        src = "{{ item }}"
      , dest = "{{ stiltweb_bindir }}/"
      , owner = "{{ stiltweb_username }}"
      , group = "{{ stiltweb_username }}"
      , mode = 493
    },
      with_items = Some [ "tail-latest.sh", "sync-station-names.sh", "sync-fsicos1-to-fsicos2.sh" ]
    }
]
