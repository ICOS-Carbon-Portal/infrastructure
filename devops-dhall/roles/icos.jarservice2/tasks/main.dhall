-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , tags : Optional Text
    , when : Optional (List Text)
    , name : Optional Text
    , copy : Optional ({ content : Text, dest : Text })
    , notify : Optional (List Text)
    , service : Optional ({ name : Text, enabled : Bool, state : Text })
    , uri : Optional ({ url : Text, return_content : Bool })
    , register : Optional Text
    , failed_when : Optional Text
    , retries : Optional Natural
    , delay : Optional Natural
    , until : Optional Text
    , `assert` : Optional ({ that : List Text })
  }
    , default =
        { import_tasks = None Text
    , tags = None Text
    , when = None (List Text)
    , name = None Text
    , copy = None ({ content : Text, dest : Text })
    , notify = None (List Text)
    , service = None ({ name : Text, enabled : Bool, state : Text })
    , uri = None ({ url : Text, return_content : Bool })
    , register = None Text
    , failed_when = None Text
    , retries = None Natural
    , delay = None Natural
    , until = None Text
    , `assert` = None ({ that : List Text })
  }
    }

in  [
    Item::{
      import_tasks = Some "jarfile.yml",
      tags = Some "jarservice_jarfile",
      when = Some [ "jarservice_jar_enable | bool" ]
    }
  , Item::{
      name = Some "Add systemd {{ jarservice_name }} servicefile",
      copy = Some {
        content = "{{ jarservice_unit }}"
      , dest = "/etc/systemd/system/{{ jarservice_name }}.service"
    },
      notify = Some [ "reload systemd config" ]
    }
  , Item::{
      name = Some "Enable systemd {{ jarservice_name }}",
      service = Some {
        name = "{{ jarservice_name }}"
      , enabled = True
      , state = "{{ jarservice_state | default('started') }}"
    }
    }
  , Item::{
      when = Some [ "jarservice_check is defined" ],
      name = Some "Check that the service responds",
      uri = Some { url = "{{ jarservice_check }}", return_content = True },
      register = Some "r",
      failed_when = Some "r.failed",
      retries = Some 30,
      delay = Some 10,
      until = Some "not r.failed"
    }
  , Item::{
      when = Some [ "jarservice_check is defined", "jarservice_githash is defined" ],
      name = Some "Check that the gitHash is correct",
      `assert` = Some { that = [ "jarservice_githash in r.content" ] }
    }
]
