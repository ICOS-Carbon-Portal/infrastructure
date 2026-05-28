-- Auto-generated from nginx.yml

let Item =
    { Type =
        { include_role : Optional Text
    , name : Optional Text
    , template : Optional ({ src : Text, dest : Text, mode : Natural })
    , notify : Optional Text
  }
    , default =
        { include_role = None Text
    , name = None Text
    , template = None ({ src : Text, dest : Text, mode : Natural })
    , notify = None Text
  }
    }

in  [
    Item::{ include_role = Some "name=icos.certbot" }
  , Item::{
      name = Some "Copy nginx conf",
      template = Some { src = "sites-aquanet-form.conf", dest = "/etc/nginx/conf.d/", mode = 448 },
      notify = Some "reload nginx config"
    }
]
