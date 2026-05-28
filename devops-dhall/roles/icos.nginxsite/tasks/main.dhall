-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , `assert` : Optional ({ that : Text })
    , include_tasks : Optional ({ file : Text })
    , when : Optional Text
  }
    , default =
        { `assert` = None ({ that : Text })
    , include_tasks = None ({ file : Text })
    , when = None Text
  }
    }

in  [
    Entry::{
      name = "make sure we understand nginxsite_state",
      `assert` = Some { that = "nginxsite_state in ['present', 'absent']" }
    }
  , Entry::{
      name = "add site",
      include_tasks = Some { file = "present.yml" },
      when = Some "nginxsite_state == 'present'"
    }
  , Entry::{
      name = "remove site",
      include_tasks = Some { file = "absent.yml" },
      when = Some "nginxsite_state == 'absent'"
    }
]
