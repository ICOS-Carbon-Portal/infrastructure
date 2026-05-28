-- Auto-generated from main.yml

let Entry =
    { Type =
        { name : Text
    , check_mode : Optional Bool
    , shellfact : Optional ({ exec : Text, fact : Text })
    , failed_when : Optional Bool
    , debug : Optional ({ msg : Text })
    , when : Optional (List Text)
    , import_tasks : Optional Text
  }
    , default =
        { check_mode = None Bool
    , shellfact = None ({ exec : Text, fact : Text })
    , failed_when = None Bool
    , debug = None ({ msg : Text })
    , when = None (List Text)
    , import_tasks = None Text
  }
    }

in  [
    Entry::{
      name = "Retrieve version of installed golang (if any)",
      check_mode = Some False,
      shellfact = Some { exec = "go version | cut -c14-20", fact = "golang_local_version" },
      failed_when = Some False
    }
  , Entry::{
      name = "Is the installed version of golang sufficent?",
      debug = Some { msg = "{{ golang_local_version }} is sufficient." },
      when = Some [ "golang_local_version_ok" ]
    }
  , Entry::{
      name = "Installing golang from apt",
      when = Some [ "not golang_local_version_ok" ],
      import_tasks = Some "apt_install.yml"
    }
  , Entry::{
      name = "Installing golang from source",
      when = Some [ "not golang_local_version_ok", "not golang_apt_version_ok" ],
      import_tasks = Some "download_install.yml"
    }
]
