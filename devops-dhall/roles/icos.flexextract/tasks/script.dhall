-- Auto-generated from script.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text })
    , copy : Optional ({ src : Optional Text, dest : Text, mode : Text, content : Optional Text })
    , register : Optional Text
  }
    , default =
        { file = None ({ path : Text, state : Text })
    , copy = None ({ src : Optional Text, dest : Text, mode : Text, content : Optional Text })
    , register = None Text
  }
    }

in  [
    Task::{
      name = "Create {{ flexextract_bin_dir }} directory",
      file = Some { path = "{{ flexextract_bin_dir }}", state = "directory" }
    }
  , Task::{
      name = "Copy flexextract script",
      copy = Some {
        src = Some "flexextract.sh"
      , dest = "{{ flexextract_bin_dir }}/"
      , mode = "-x"
      , content = None Text
    },
      register = Some "_script"
    }
  , Task::{
      name = "Create flexextract wrapper",
      copy = Some {
        src = None Text
      , dest = "{{ flexextract_bin_dir }}/flexextract"
      , mode = "+x"
      , content = Some ''
        #!/bin/bash
        TAG="{{ flexextract_tag }}"
        HOST_DIR="{{ flexextract_download_host }}"
        CONT_DIR="{{ flexextract_download_cont }}"
        source "{{ _script.dest }}"

      ''
    }
    }
]
