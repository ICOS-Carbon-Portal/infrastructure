-- Auto-generated from certbot.yml

let Task =
    { Type =
        { name : Text
    , `community.general.snap` : Optional ({ name : Text, classic : Bool })
    , cron : Optional ({ name : Text, job : Text, special_time : Text })
    , file : Optional ({ path : Text, state : Text })
    , copy : Optional ({ dest : Text, mode : Text, content : Text })
    , tags : Optional Text
    , import_role : Optional ({ name : Text })
    , vars : Optional ({ python_util_src : Text })
  }
    , default =
        { `community.general.snap` = None ({ name : Text, classic : Bool })
    , cron = None ({ name : Text, job : Text, special_time : Text })
    , file = None ({ path : Text, state : Text })
    , copy = None ({ dest : Text, mode : Text, content : Text })
    , tags = None Text
    , import_role = None ({ name : Text })
    , vars = None ({ python_util_src : Text })
  }
    }

in  [
    Task::{
      name = "Install certbot using snap",
      `community.general.snap` = Some { name = "certbot", classic = True }
    }
  , Task::{
      name = "Add job to renew certificates",
      cron = Some {
        name = "Certbot renewal"
      , job = "{{ nginx_certbot_bin }} renew -q"
      , special_time = "daily"
    }
    }
  , Task::{
      name = "Create /etc/letsencrypt/renewal-hooks/deploy directory",
      file = Some { path = "/etc/letsencrypt/renewal-hooks/deploy", state = "directory" }
    }
  , Task::{
      name = "Add a nginx deploy-hook for certbot",
      copy = Some {
        dest = "/etc/letsencrypt/renewal-hooks/deploy/nginx.sh"
      , mode = "+x"
      , content = ''
        #!/bin/bash
        service nginx reload

      ''
    }
    }
  , Task::{
      name = "Install the icos-certbot util",
      tags = Some "certbot_utils",
      import_role = Some { name = "icos.python_util" },
      vars = Some { python_util_src = "certbot_util" }
    }
]
