-- Auto-generated from ../devops/server-fsicos3.yml

[
    {
      hosts = "fsicos3"
    , roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , when : Optional Text
      }
        , default =
            { when = None Text
      }
        }

    in  [
        Role::{ role = "icos.server", tags = "server", when = Some "not ansible_check_mode" }
      , Role::{ role = "icos.lxd_server", tags = "lxd" }
      , Role::{ role = "icos.nginx", tags = "nginx" }
      , Role::{ role = "icos.podman", tags = "podman" }
      , Role::{ role = "ops.zfs", tags = "zfs" }
    ]
  }
]
