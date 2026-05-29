-- Auto-generated from ctop.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove /usr/local/sbin/ctop",
      file = Some {
        path = None Text
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = Some "/usr/local/sbin/ctop"
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
]
