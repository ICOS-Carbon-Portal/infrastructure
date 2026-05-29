-- Auto-generated from ../devops/vm-fsicos4-fdp.yml

[
    {
      hosts = "fsicos4",
      roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , caddy_name : Optional Text
        , caddy_conf : Optional Text
      }
        , default =
            { caddy_name = None Text
        , caddy_conf = None Text
      }
        }

    in  [
        Role::{
          role = "icos.caddy",
          tags = "caddy",
          caddy_name = Some "fdpdemo",
          caddy_conf = Some ''
          fdpdemo.envri.eu {
              reverse_proxy 10.10.10.236:80
          }

        ''
        }
    ]
    }
  , {
      hosts = "fdp",
      roles = let Role =
        { Type =
            { role : Text
        , tags : Text
        , caddy_name : Optional Text
        , caddy_conf : Optional Text
      }
        , default =
            { caddy_name = None Text
        , caddy_conf = None Text
      }
        }

    in  [
        Role::{ role = "icos.fairdatapoint", tags = "fairdatapoint" }
    ]
    }
]
