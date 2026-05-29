-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Retrieve version of installed golang (if any)",
      check_mode = Some False,
      shellfact = Some {
        exec = "go version | cut -c14-20"
      , fact = "golang_local_version"
      , bool = None Bool
      , list = None Bool
    },
      failed_when = Some "False"
    }
  , Task::{
      name = Some "Is the installed version of golang sufficent?",
      debug = Some { msg = "{{ golang_local_version }} is sufficient." },
      when = Some [ "golang_local_version_ok" ]
    }
  , Task::{
      name = Some "Installing golang from apt",
      import_tasks = Some "apt_install.yml",
      when = Some [ "not golang_local_version_ok" ]
    }
  , Task::{
      name = Some "Installing golang from source",
      import_tasks = Some "download_install.yml",
      when = Some [ "not golang_local_version_ok", "not golang_apt_version_ok" ]
    }
]
