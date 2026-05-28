-- Auto-generated from zfs-and-lxd.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : List Text })
    , copy : Optional ({ dest : Text, content : Text })
  }
    , default =
        { apt = None ({ name : List Text })
    , copy = None ({ dest : Text, content : Text })
  }
    }

in  [
    Task::{ name = "Install fuse-overlayfs", apt = Some { name = [ "fuse-overlayfs" ] } }
  , Task::{
      name = "Configure storage.conf",
      copy = Some {
        dest = "/etc/containers/storage.conf"
      , content = ''
        [storage]
        driver = "overlay"
        graphroot = "/var/lib/containers/storage"

      ''
    }
    }
]
