-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , authorized_key : Optional ({ user : Text, state : Text, key : Text, exclusive : Bool })
    , when : Optional Text
    , timezone : Optional ({ name : Text })
    , notify : Optional Text
    , locale_gen : Optional ({ name : Text, state : Text })
    , loop : Optional (List Text)
  }
    , default =
        { authorized_key = None ({ user : Text, state : Text, key : Text, exclusive : Bool })
    , when = None Text
    , timezone = None ({ name : Text })
    , notify = None Text
    , locale_gen = None ({ name : Text, state : Text })
    , loop = None (List Text)
  }
    }

in  [
    Entry::{
      name = "Install public keys",
      authorized_key = Some {
        user = "root"
      , state = "present"
      , key = "{{ root_keys }}"
      , exclusive = True
    },
      when = Some "root_keys is truthy"
    }
  , Entry::{
      name = "Set timezone to Europe/Stockholm",
      timezone = Some { name = "Europe/Stockholm" },
      notify = Some "restart cron"
    }
  , Entry::{
      name = "Generate locale",
      locale_gen = Some { name = "{{ item }}", state = "present" },
      loop = Some [ "en_US.UTF-8", "sv_SE.UTF-8" ]
    }
]
