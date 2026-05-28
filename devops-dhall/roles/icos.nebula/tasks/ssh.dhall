-- Auto-generated from ssh.yml

let Entry =
    { Type =
        { name : Text
    , command : Optional Text
    , args : Optional ({ creates : Text })
    , slurp : Optional ({ src : Text })
    , register : Optional Text
    , set_fact : Optional ({ nebula_ssh_public : Text })
  }
    , default =
        { command = None Text
    , args = None ({ creates : Text })
    , slurp = None ({ src : Text })
    , register = None Text
    , set_fact = None ({ nebula_ssh_public : Text })
  }
    }

in  [
    Entry::{
      name = "Generate admin ssh key",
      command = Some ''
      ssh-keygen -q -t ed25519
        -f {{ nebula_ssh_key }}
        -C "nebula admin on {{ nebula_hostname }}" -N ""
    '',
      args = Some { creates = "{{ nebula_etc_dir }}/admin" }
    }
  , Entry::{
      name = "Slurp nebula_ssh_public",
      slurp = Some { src = "{{ nebula_ssh_key }}.pub" },
      register = Some "_slurp"
    }
  , Entry::{
      name = "Decode nebula_ssh_public",
      set_fact = Some { nebula_ssh_public = "{{ _slurp.content | b64decode }}" }
    }
]
