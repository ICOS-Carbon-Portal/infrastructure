-- Auto-generated from ../devops/stiltcluster.yml

let Play =
    { Type =
        { hosts : Text
    , handlers : Optional (List ({ name : Text, service : { name : Text, state : Text } }))
    , tasks : Optional (List ({ name : Text, tags : Text, blockinfile : { marker : Text, create : Bool, path : Text, block : Text }, notify : Text }))
    , pre_tasks : Optional (List ({ when : Text, tags : Text, block : List ({ name : Text, file : Optional ({ path : Text, state : Text }), mount : Optional ({ src : Text, path : Text, state : Text, fstype : Text }) }) }))
    , roles : Optional (List ({ role : Text, tags : Text }))
  }
    , default =
        { handlers = None (List ({ name : Text, service : { name : Text, state : Text } }))
    , tasks = None (List ({ name : Text, tags : Text, blockinfile : { marker : Text, create : Bool, path : Text, block : Text }, notify : Text }))
    , pre_tasks = None (List ({ when : Text, tags : Text, block : List ({ name : Text, file : Optional ({ path : Text, state : Text }), mount : Optional ({ src : Text, path : Text, state : Text, fstype : Text }) }) }))
    , roles = None (List ({ role : Text, tags : Text }))
  }
    }

in  [
    Play::{
      hosts = "fsicos2",
      handlers = Some [
        {
          name = "reload nfs server"
        , service = { name = "nfs-server", state = "reloaded" }
      }
    ],
      tasks = Some [
        {
          name = "Export stilt input data"
        , tags = "inputdata"
        , blockinfile = {
            marker = "# {mark} stiltcluster"
          , create = True
          , path = "/etc/exports"
          , block = ''
            /disk/data/stilt            *.nebula(ro,no_root_squash)

          ''
        }
        , notify = "reload nfs server"
      }
    ]
    }
  , Play::{
      hosts = "stiltcluster_hosts",
      pre_tasks = Some [
        {
          when = "stilt_input_mount | default(False)"
        , tags = "inputdata"
        , block = let Entry =
            { Type =
                { name : Text
            , file : Optional ({ path : Text, state : Text })
            , mount : Optional ({ src : Text, path : Text, state : Text, fstype : Text })
          }
            , default =
                { file = None ({ path : Text, state : Text })
            , mount = None ({ src : Text, path : Text, state : Text, fstype : Text })
          }
            }

        in  [
            Entry::{
              name = "Create stilt input dir",
              file = Some { path = "{{ stilt_input_dir }}", state = "directory" }
            }
          , Entry::{
              name = "Mount stilt input data",
              mount = Some {
                src = "fsicos2.nebula:/disk/data/stilt/Input"
              , path = "{{ stilt_input_dir }}"
              , state = "mounted"
              , fstype = "nfs4"
            }
            }
        ]
      }
    ],
      roles = Some [
        { role = "icos.stiltrun", tags = "stiltrun" }
      , { role = "icos.stiltcluster", tags = "stiltcluster" }
    ]
    }
]
