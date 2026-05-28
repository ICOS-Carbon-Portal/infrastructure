-- Auto-generated from apt_install.yml

let Task =
    { Type =
        { name : Text
    , check_mode : Optional Bool
    , shellfact : Optional ({ exec : Text, fact : Text })
    , apt : Optional ({ name : Text })
    , when : Optional Text
  }
    , default =
        { check_mode = None Bool
    , shellfact = None ({ exec : Text, fact : Text })
    , apt = None ({ name : Text })
    , when = None Text
  }
    }

in  [
    Task::{
      name = "Retrieve conmon_apt_version fact",
      check_mode = Some False,
      shellfact = Some {
        exec = "apt show conmon 2>/dev/null |  perl -ne '/Version: ([0-9.]+)/ && print $1'"
      , fact = "conmon_apt_version"
    }
    }
  , Task::{
      name = "install conmon using apt",
      apt = Some { name = "conmon" },
      when = Some "conmon_apt_version_ok"
    }
]
