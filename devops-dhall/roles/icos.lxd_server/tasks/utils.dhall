-- Auto-generated from utils.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Copy utilities",
      copy = Some {
        src = Some "{{ item }}"
      , dest = "/usr/local/sbin/{{ item }}"
      , mode = Some "493"
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      loop = Some [ "lxdfs" ]
    }
]
