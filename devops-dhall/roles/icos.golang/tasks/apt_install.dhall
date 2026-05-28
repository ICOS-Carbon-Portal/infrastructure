-- Auto-generated from apt_install.yml

let Task =
    { Type =
        { name : Text
    , check_mode : Optional Bool
    , shellfact : Optional ({ exec : Text, fact : Text })
    , when : Optional Text
    , apt : Optional ({ name : Text })
  }
    , default =
        { check_mode = None Bool
    , shellfact = None ({ exec : Text, fact : Text })
    , when = None Text
    , apt = None ({ name : Text })
  }
    }

in  [
    Task::{
      name = "Retrieve golang_apt_version fact",
      check_mode = Some False,
      shellfact = Some {
        exec = "apt show golang-go 2>/dev/null | perl -ne '/Version: 2:([0-9.]+)/ && print $1'"
      , fact = "golang_apt_version"
    }
    }
  , Task::{
      name = "install golang using apt",
      when = Some "golang_apt_version_ok",
      apt = Some { name = "golang" }
    }
]
