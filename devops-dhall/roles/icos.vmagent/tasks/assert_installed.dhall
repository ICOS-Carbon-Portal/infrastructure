-- Auto-generated from assert_installed.yml

let Entry =
    { Type =
        { name : Text
    , stat : Optional ({ path : Text })
    , register : Optional Text
    , fail : Optional ({ msg : Text })
    , when : Optional Text
  }
    , default =
        { stat = None ({ path : Text })
    , register = None Text
    , fail = None ({ msg : Text })
    , when = None Text
  }
    }

in  [
    Entry::{
      name = "Check whether vmagent is installed",
      stat = Some { path = "{{ vmagent_configs }}" },
      register = Some "_r"
    }
  , Entry::{
      name = "Fail if vmagent isn't installed",
      fail = Some { msg = "vmagent isn't installed on this machine" },
      when = Some "not _r.stat.exists"
    }
]
