-- Auto-generated from ca.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy Certificate Authority",
      copy = Some {
        src = Some "{{ nebula_cert_copy }}"
      , dest = "{{ nebula_etc_dir }}/ca.crt"
      , mode = None Text
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      notify = Some [ "reload nebula" ]
    }
]
