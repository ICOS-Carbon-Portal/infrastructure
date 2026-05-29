-- Auto-generated from zfs-and-lxd.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install fuse-overlayfs",
      apt = Some {
        name = Some [ "fuse-overlayfs" ]
      , state = None Text
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
      name = Some "Configure storage.conf",
      copy = Some {
        src = None Text
      , dest = "/etc/containers/storage.conf"
      , mode = None Text
      , content = Some ''
        [storage]
        driver = "overlay"
        graphroot = "/var/lib/containers/storage"

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
]
