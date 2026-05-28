-- Auto-generated from just.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ src : Text, dest : Text, mode : Text })
    , register : Optional Text
    , shell : Optional Text
    , changed_when : Optional Bool
  }
    , default =
        { copy = None ({ src : Text, dest : Text, mode : Text })
    , register = None Text
    , shell = None Text
    , changed_when = None Bool
  }
    }

in  [
    Task::{
      name = "Copy ops-borg",
      copy = Some { src = "ops-borg", dest = "/usr/local/bin/ops-borg", mode = "+x" },
      register = Some "_justfile"
    }
  , Task::{
      name = "Check that the justfile is executable",
      shell = Some "{{ _justfile.dest }}",
      changed_when = Some False
    }
]
