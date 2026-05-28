-- Auto-generated from nginx.yml

let Item =
    { Type =
        { import_role : Optional Text
    , when : Optional Text
    , name : Optional Text
    , uri : Optional ({ url : Text, return_content : Bool })
    , register : Optional Text
    , failed_when : Optional (List Text)
    , retries : Optional Natural
    , delay : Optional Natural
    , until : Optional Text
  }
    , default =
        { import_role = None Text
    , when = None Text
    , name = None Text
    , uri = None ({ url : Text, return_content : Bool })
    , register = None Text
    , failed_when = None (List Text)
    , retries = None Natural
    , delay = None Natural
    , until = None Text
  }
    }

in  [
    Item::{
      import_role = Some "name=icos.certbot2",
      when = Some "nexus_certbot_enable | default(True)"
    }
  , Item::{ import_role = Some "name=icos.nginxsite" }
  , Item::{
      name = Some "Check that nexus responds with correct version",
      uri = Some {
        url = "http://127.0.0.1:{{ nexus_host_port }}/service/local/status"
      , return_content = True
    },
      register = Some "r",
      failed_when = Some [ "not ((\"<version>%s</version>\" % nexus_version) in r.content)" ],
      retries = Some 2,
      delay = Some 10,
      until = Some "not r.failed"
    }
]
