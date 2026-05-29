-- Auto-generated from ../../../../devops/roles/icos.flexextract/tasks/script.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create {{ flexextract_bin_dir }} directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ flexextract_bin_dir }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Copy flexextract script",
      copy = Some {
        dest = "{{ flexextract_bin_dir }}/",
        mode = Some "-x",
        content = None Text,
        src = Some "flexextract.sh",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      register = Some "_script"
    }
  , Task::{
      name = Some "Create flexextract wrapper",
      copy = Some {
        dest = "{{ flexextract_bin_dir }}/flexextract",
        mode = Some "+x",
        content = Some ''
        #!/bin/bash
        TAG="{{ flexextract_tag }}"
        HOST_DIR="{{ flexextract_download_host }}"
        CONT_DIR="{{ flexextract_download_cont }}"
        source "{{ _script.dest }}"

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
]
