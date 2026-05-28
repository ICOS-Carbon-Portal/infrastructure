-- Auto-generated from vm-fsicos4-stiltcluster.yml

let Play =
    { Type =
        { hosts : Text
    , tasks : Optional (List ({ name : Text, fetch : { src : Text, dest : Text, flat : Bool } }))
    , roles : Optional (List ({ role : Text, tags : Text }))
  }
    , default =
        { tasks = None (List ({ name : Text, fetch : { src : Text, dest : Text, flat : Bool } }))
    , roles = None (List ({ role : Text, tags : Text }))
  }
    }

in  [
    Play::{
      hosts = "fsicos2",
      tasks = Some [
        {
          name = "Retrive stiltcluster.jar"
        , fetch = {
            src = "/home/stiltcluster/stiltcluster.jar"
          , dest = "tmp/stiltcluster.jar"
          , flat = True
        }
      }
    ]
    }
  , Play::{
      hosts = "fsicos4-stiltcluster",
      roles = Some [
        { role = "icos.pve_guest", tags = "guest" }
      , { role = "icos.python3", tags = "python3" }
      , { role = "icos.docker2", tags = "docker" }
      , { role = "icos.stiltrun", tags = "stiltrun" }
      , { role = "icos.stiltcluster", tags = "stiltcluster" }
    ]
    }
]
