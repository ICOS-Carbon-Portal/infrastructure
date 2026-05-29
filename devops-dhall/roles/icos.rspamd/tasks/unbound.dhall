-- Auto-generated from unbound.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install resolvconf",
      apt = Some {
        name = Some [ "resolvconf" ]
      , state = Some "present"
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Install unbound",
      apt = Some {
        name = Some [ "unbound" ]
      , state = Some "present"
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
]
