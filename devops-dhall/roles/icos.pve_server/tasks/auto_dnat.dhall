-- Auto-generated from auto_dnat.yml

let Entry =
    { Type =
        { name : Text
    , `ansible.posix.synchronize` : Optional ({ src : Text, dest : Text, owner : Bool, group : Bool, rsync_opts : List Text })
    , register : Optional Text
    , `community.general.pipx` : Optional ({ executable : Text, python : Text, editable : Bool, force : Bool, name : Text })
    , when : Optional Text
    , changed_when : Optional (List Text)
    , template : Optional ({ src : Text, dest : Text, lstrip_blocks : Bool })
    , loop : Optional (List Text)
    , systemd : Optional ({ `daemon-reload` : Optional Bool, name : Optional Text, enabled : Optional Bool, state : Optional Text })
  }
    , default =
        { `ansible.posix.synchronize` = None ({ src : Text, dest : Text, owner : Bool, group : Bool, rsync_opts : List Text })
    , register = None Text
    , `community.general.pipx` = None ({ executable : Text, python : Text, editable : Bool, force : Bool, name : Text })
    , when = None Text
    , changed_when = None (List Text)
    , template = None ({ src : Text, dest : Text, lstrip_blocks : Bool })
    , loop = None (List Text)
    , systemd = None ({ `daemon-reload` : Optional Bool, name : Optional Text, enabled : Optional Bool, state : Optional Text })
  }
    }

in  [
    Entry::{
      name = "Synchronize icos-auto-dnat source",
      `ansible.posix.synchronize` = Some {
        src = "icos-auto-dnat/"
      , dest = "/opt/icos-auto-dnat"
      , owner = False
      , group = False
      , rsync_opts = [ "-F", "--delete-excluded" ]
    },
      register = Some "_rsync"
    }
  , Entry::{
      name = "Install icos-auto-dnat",
      register = Some "_pipx",
      `community.general.pipx` = Some {
        executable = "pipx-global"
      , python = "python3"
      , editable = True
      , force = True
      , name = "/opt/icos-auto-dnat/"
    },
      when = Some "_rsync.changed",
      changed_when = Some [
        "_pipx.changed"
      , "_pipx.stdout"
      , "_pipx.stdout.find('already seems to be installed') == -1"
    ]
    }
  , Entry::{
      name = "Copy auto-dnat service files",
      register = Some "_systemd",
      template = Some { src = "{{ item }}", dest = "/etc/systemd/system/", lstrip_blocks = True },
      loop = Some [ "icos-auto-dnat.path", "icos-auto-dnat.timer", "icos-auto-dnat.service" ]
    }
  , Entry::{
      name = "Reload systemd",
      when = Some "_systemd.changed",
      systemd = Some {
        `daemon-reload` = Some True
      , name = None Text
      , enabled = None Bool
      , state = None Text
    }
    }
  , Entry::{
      name = "Start service",
      loop = Some [ "icos-auto-dnat.path", "icos-auto-dnat.timer" ],
      systemd = Some {
        `daemon-reload` = None Bool
      , name = Some "{{ item }}"
      , enabled = Some True
      , state = Some "{{ 'restarted' if _systemd.changed else 'started' }}"
    }
    }
]
