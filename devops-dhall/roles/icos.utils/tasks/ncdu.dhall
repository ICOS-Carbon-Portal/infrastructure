-- Auto-generated from ncdu.yml

let Entry =
    { Type =
        { name : Text
    , tags : Optional Text
    , unarchive : Optional ({ remote_src : Bool, src : Text, dest : Text })
    , register : Optional Text
    , diff : Optional Bool
    , command : Optional Text
    , changed_when : Optional Bool
    , debug : Optional ({ msg : Text })
  }
    , default =
        { tags = None Text
    , unarchive = None ({ remote_src : Bool, src : Text, dest : Text })
    , register = None Text
    , diff = None Bool
    , command = None Text
    , changed_when = None Bool
    , debug = None ({ msg : Text })
  }
    }

in  [
    Entry::{
      name = "Install ncdu",
      tags = Some "ncdu",
      unarchive = Some { remote_src = True, src = "{{ ncdu_url }}", dest = "/usr/local/bin/" },
      register = Some "_ncdu",
      diff = Some False
    }
  , Entry::{
      name = "Check that ncdu is executable",
      register = Some "_version",
      command = Some "{{ _ncdu.dest }}/ncdu --version",
      changed_when = Some False
    }
  , Entry::{
      name = "Which version of ncdu was installed",
      debug = Some { msg = "Installed {{ _version.stdout }}" }
    }
]
