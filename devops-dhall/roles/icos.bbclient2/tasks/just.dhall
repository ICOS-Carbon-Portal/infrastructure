-- Auto-generated from just.yml

let Task =
    { Type =
        { name : Text
    , template : Optional ({ src : Text, dest : Text, variable_start_string : Text, variable_end_string : Text, lstrip_blocks : Bool })
    , copy : Optional ({ src : Text, dest : Text, mode : Text })
  }
    , default =
        { template = None ({ src : Text, dest : Text, variable_start_string : Text, variable_end_string : Text, lstrip_blocks : Bool })
    , copy = None ({ src : Text, dest : Text, mode : Text })
  }
    }

in  [
    Task::{
      name = "Copy justfile",
      template = Some {
        src = "justfile"
      , dest = "{{ bbclient_home }}/"
      , variable_start_string = "{{ '{{{{' }}"
      , variable_end_string = "{{ '}}}}' }}"
      , lstrip_blocks = True
    }
    }
  , Task::{
      name = "Copy systemd-wide justfile",
      copy = Some { src = "ops-bbclient", dest = "/usr/local/bin/", mode = "+x" }
    }
]
