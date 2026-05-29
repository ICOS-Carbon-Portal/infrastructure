-- Auto-generated from script.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create {{ flexextract_bin_dir }} directory",
      file = Some {
        path = Some "{{ flexextract_bin_dir }}"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Copy flexextract script",
      copy = Some {
        src = Some "flexextract.sh"
      , dest = "{{ flexextract_bin_dir }}/"
      , mode = Some "-x"
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      register = Some "_script"
    }
  , Task::{
      name = Some "Create flexextract wrapper",
      copy = Some {
        src = None Text
      , dest = "{{ flexextract_bin_dir }}/flexextract"
      , mode = Some "+x"
      , content = Some ''
        #!/bin/bash
        TAG="{{ flexextract_tag }}"
        HOST_DIR="{{ flexextract_download_host }}"
        CONT_DIR="{{ flexextract_download_cont }}"
        source "{{ _script.dest }}"

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
]
