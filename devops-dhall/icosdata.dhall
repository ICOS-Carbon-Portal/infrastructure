-- Auto-generated from ../devops/icosdata.yml

let Play =
    { Type =
        { hosts : List Text
    , tags : Optional (List Text)
    , tasks : List ({ name : Text, tags : Optional Text, zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : { mountpoint : Text } }), when : Optional Text, apt : Optional ({ name : List Text, state : Optional Text }), file : Optional ({ path : Text, state : Text }), loop : Optional Text, mount : Optional ({ fstype : Text, state : Text, path : Text, src : Text, opts : Text }), blockinfile : Optional ({ path : Text, create : Bool, marker : Text, block : Text }), notify : Optional Text, command : Optional Text, changed_when : Optional Bool, lxd_profile : Optional ({ name : Text, devices : { radonmap : { path : Text, source : Text, type : Text, readonly : Text }, stilt : { path : Text, source : Text, type : Text, readonly : Text }, fluxcom_upload : { path : Text, source : Text, type : Text, readonly : Text } } }) })
    , handlers : Optional (List ({ name : Text, service : { name : Text, state : Text } }))
  }
    , default =
        { tags = None (List Text)
    , handlers = None (List ({ name : Text, service : { name : Text, state : Text } }))
  }
    }

in  [
    Play::{
      hosts = [ "fsicos3" ],
      tags = Some [ "zfs" ],
      tasks = let Entry =
        { Type =
            { name : Text
        , tags : Optional Text
        , zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : { mountpoint : Text } })
        , when : Optional Text
        , apt : Optional ({ name : List Text, state : Optional Text })
        , file : Optional ({ path : Text, state : Text })
        , loop : Optional Text
        , mount : Optional ({ fstype : Text, state : Text, path : Text, src : Text, opts : Text })
        , blockinfile : Optional ({ path : Text, create : Bool, marker : Text, block : Text })
        , notify : Optional Text
        , command : Optional Text
        , changed_when : Optional Bool
        , lxd_profile : Optional ({ name : Text, devices : { radonmap : { path : Text, source : Text, type : Text, readonly : Text }, stilt : { path : Text, source : Text, type : Text, readonly : Text }, fluxcom_upload : { path : Text, source : Text, type : Text, readonly : Text } } })
      }
        , default =
            { tags = None Text
        , zfs = None ({ name : Text, state : Text, extra_zfs_properties : { mountpoint : Text } })
        , when = None Text
        , apt = None ({ name : List Text, state : Optional Text })
        , file = None ({ path : Text, state : Text })
        , loop = None Text
        , mount = None ({ fstype : Text, state : Text, path : Text, src : Text, opts : Text })
        , blockinfile = None ({ path : Text, create : Bool, marker : Text, block : Text })
        , notify = None Text
        , command = None Text
        , changed_when = None Bool
        , lxd_profile = None ({ name : Text, devices : { radonmap : { path : Text, source : Text, type : Text, readonly : Text }, stilt : { path : Text, source : Text, type : Text, readonly : Text }, fluxcom_upload : { path : Text, source : Text, type : Text, readonly : Text } } })
      }
        }

    in  [
        Entry::{
          name = "Create /incoming",
          tags = Some "incoming",
          zfs = Some {
            name = "pool/incoming"
          , state = "present"
          , extra_zfs_properties = { mountpoint = "/incoming" }
        }
        }
    ]
    }
  , Play::{
      hosts = [
        "fsicos2"
      , "fsicos3"
      , "icos1"
      , "cupcake"
      , "pancake"
    ],
      tags = Some [ "nfs" ],
      tasks = let Task =
        { Type =
            { name : Text
        , tags : Optional Text
        , zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : { mountpoint : Text } })
        , when : Optional Text
        , apt : Optional ({ name : List Text, state : Optional Text })
        , file : Optional ({ path : Text, state : Text })
        , loop : Optional Text
        , mount : Optional ({ fstype : Text, state : Text, path : Text, src : Text, opts : Text })
        , blockinfile : Optional ({ path : Text, create : Bool, marker : Text, block : Text })
        , notify : Optional Text
        , command : Optional Text
        , changed_when : Optional Bool
        , lxd_profile : Optional ({ name : Text, devices : { radonmap : { path : Text, source : Text, type : Text, readonly : Text }, stilt : { path : Text, source : Text, type : Text, readonly : Text }, fluxcom_upload : { path : Text, source : Text, type : Text, readonly : Text } } })
      }
        , default =
            { tags = None Text
        , zfs = None ({ name : Text, state : Text, extra_zfs_properties : { mountpoint : Text } })
        , when = None Text
        , apt = None ({ name : List Text, state : Optional Text })
        , file = None ({ path : Text, state : Text })
        , loop = None Text
        , mount = None ({ fstype : Text, state : Text, path : Text, src : Text, opts : Text })
        , blockinfile = None ({ path : Text, create : Bool, marker : Text, block : Text })
        , notify = None Text
        , command = None Text
        , changed_when = None Bool
        , lxd_profile = None ({ name : Text, devices : { radonmap : { path : Text, source : Text, type : Text, readonly : Text }, stilt : { path : Text, source : Text, type : Text, readonly : Text }, fluxcom_upload : { path : Text, source : Text, type : Text, readonly : Text } } })
      }
        }

    in  [
        Task::{
          name = "Install packages",
          when = Some "icosdata_exports is defined",
          apt = Some { name = [ "nfs-kernel-server" ], state = Some "present" }
        }
      , Task::{
          name = "Install nfs-client",
          when = Some "icosdata_nfs_mounts is defined",
          apt = Some { name = [ "nfs-client" ], state = None Text }
        }
      , Task::{
          name = "Create directories",
          file = Some { path = "{{ item }}", state = "directory" },
          loop = Some "{{ icosdata_mkdirs | default([]) }}"
        }
      , Task::{
          name = "Do bind-mount local data",
          loop = Some "{{ icosdata_bind_mounts | default([]) }}",
          mount = Some {
            fstype = "none"
          , state = "mounted"
          , path = "{{ item.path }}"
          , src = "{{ item.src }}"
          , opts = "bind{{ item.opts | default('') }}"
        }
        }
      , Task::{
          name = "Export data via nfs",
          tags = Some "export",
          when = Some "icosdata_exports is defined",
          blockinfile = Some {
            path = "/etc/exports"
          , create = True
          , marker = "# {mark} icosdata"
          , block = "{{ icosdata_exports }}"
        },
          notify = Some "Reload NFS server"
        }
      , Task::{
          name = "Export all directories listed in `/etc/exports`",
          tags = Some "export",
          when = Some "icosdata_exports is defined",
          command = Some "exportfs -rav",
          changed_when = Some False
        }
      , Task::{
          name = "Mount nfs data",
          tags = Some "mount",
          when = Some "icosdata_nfs_mounts is defined",
          loop = Some "{{ icosdata_nfs_mounts }}",
          mount = Some {
            fstype = "nfs4"
          , state = "{{ item.state | default('mounted') }}"
          , src = "{{ item.src | default(omit) }}"
          , path = "{{ item.path | default(omit) }}"
          , opts = "{{ item.opts | default('ro') }}"
        }
        }
    ],
      handlers = Some [
        {
          name = "Reload NFS server"
        , service = { name = "nfs-server", state = "reloaded" }
      }
    ]
    }
  , Play::{
      hosts = [ "fsicos3" ],
      tasks = let Entry =
        { Type =
            { name : Text
        , tags : Optional Text
        , zfs : Optional ({ name : Text, state : Text, extra_zfs_properties : { mountpoint : Text } })
        , when : Optional Text
        , apt : Optional ({ name : List Text, state : Optional Text })
        , file : Optional ({ path : Text, state : Text })
        , loop : Optional Text
        , mount : Optional ({ fstype : Text, state : Text, path : Text, src : Text, opts : Text })
        , blockinfile : Optional ({ path : Text, create : Bool, marker : Text, block : Text })
        , notify : Optional Text
        , command : Optional Text
        , changed_when : Optional Bool
        , lxd_profile : Optional ({ name : Text, devices : { radonmap : { path : Text, source : Text, type : Text, readonly : Text }, stilt : { path : Text, source : Text, type : Text, readonly : Text }, fluxcom_upload : { path : Text, source : Text, type : Text, readonly : Text } } })
      }
        , default =
            { tags = None Text
        , zfs = None ({ name : Text, state : Text, extra_zfs_properties : { mountpoint : Text } })
        , when = None Text
        , apt = None ({ name : List Text, state : Optional Text })
        , file = None ({ path : Text, state : Text })
        , loop = None Text
        , mount = None ({ fstype : Text, state : Text, path : Text, src : Text, opts : Text })
        , blockinfile = None ({ path : Text, create : Bool, marker : Text, block : Text })
        , notify = None Text
        , command = None Text
        , changed_when = None Bool
        , lxd_profile = None ({ name : Text, devices : { radonmap : { path : Text, source : Text, type : Text, readonly : Text }, stilt : { path : Text, source : Text, type : Text, readonly : Text }, fluxcom_upload : { path : Text, source : Text, type : Text, readonly : Text } } })
      }
        }

    in  [
        Entry::{
          name = "Create icosdata LXD profile",
          tags = Some "profile",
          lxd_profile = Some {
            name = "icosdata"
          , devices = {
              radonmap = {
                path = "/data/radon_map"
              , source = "/pool/ute/radon_map"
              , type = "disk"
              , readonly = "true"
            }
            , stilt = {
                path = "/data/stilt"
              , source = "/pool/ute/stilt/RINGO/T1.3/STILT"
              , type = "disk"
              , readonly = "true"
            }
            , fluxcom_upload = {
                path = "/data/fluxcom/pre_release"
              , source = "/pool/fluxcom/upload"
              , type = "disk"
              , readonly = "true"
            }
          }
        }
        }
    ]
    }
]
