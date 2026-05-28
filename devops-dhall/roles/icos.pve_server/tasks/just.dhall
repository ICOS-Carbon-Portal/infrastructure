-- Auto-generated from just.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ src : Text, dest : Text, mode : Text })
    , register : Optional Text
    , shell : Optional Text
    , changed_when : Optional Bool
    , lineinfile : Optional ({ path : Text, regex : Text, line : Text, insertafter : Text, create : Bool })
    , `ansible.builtin.shell` : Optional Text
    , args : Optional ({ executable : Text })
    , failed_when : Optional (List Text)
  }
    , default =
        { copy = None ({ src : Text, dest : Text, mode : Text })
    , register = None Text
    , shell = None Text
    , changed_when = None Bool
    , lineinfile = None ({ path : Text, regex : Text, line : Text, insertafter : Text, create : Bool })
    , `ansible.builtin.shell` = None Text
    , args = None ({ executable : Text })
    , failed_when = None (List Text)
  }
    }

in  [
    Task::{
      name = "Copy ops-proxmox-server",
      copy = Some { src = "ops-proxmox-server", dest = "/usr/local/bin/", mode = "+x" },
      register = Some "_ops"
    }
  , Task::{
      name = "Check that the justfile is executable",
      shell = Some "{{ _ops.dest }}",
      changed_when = Some False
    }
  , Task::{
      name = "Add alias for ops-proxmox-server",
      lineinfile = Some {
        path = "/root/.bashrc"
      , regex = "^alias [^=]+=ops-proxmox-server"
      , line = "alias px=ops-proxmox-server"
      , insertafter = "EOF"
      , create = False
    }
    }
  , Task::{
      name = "Check that alias and justfile works",
      register = Some "_r",
      changed_when = Some False,
      `ansible.builtin.shell` = Some "px",
      args = Some { executable = "/bin/bash" },
      failed_when = Some [ "\"onboot\" in _r.stdout" ]
    }
]
