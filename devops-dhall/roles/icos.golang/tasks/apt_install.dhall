-- Auto-generated from apt_install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Retrieve golang_apt_version fact",
      check_mode = Some False,
      shellfact = Some {
        exec = "apt show golang-go 2>/dev/null | perl -ne '/Version: 2:([0-9.]+)/ && print $1'"
      , fact = "golang_apt_version"
      , bool = None Bool
      , list = None Bool
    }
    }
  , Task::{
      name = Some "install golang using apt",
      when = Some [ "golang_apt_version_ok" ],
      apt = Some {
        name = Some [ "golang" ]
      , state = None Text
      , update_cache = None Bool
      , deb = None Text
      , purge = None Bool
      , upgrade = None Bool
      , autoclean = None Bool
      , autoremove = None Bool
      , cache_valid_time = None Text
      , install_recommends = None Bool
    }
    }
]
