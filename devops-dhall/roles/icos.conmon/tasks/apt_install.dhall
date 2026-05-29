-- Auto-generated from ../../../../devops/roles/icos.conmon/tasks/apt_install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Retrieve conmon_apt_version fact",
      check_mode = Some False,
      shellfact = Some {
        exec = "apt show conmon 2>/dev/null |  perl -ne '/Version: ([0-9.]+)/ && print $1'",
        fact = "conmon_apt_version",
        bool = None Bool,
        list = None Bool
    }
    }
  , Task::{
      name = Some "install conmon using apt",
      apt = Some {
        name = Some [ "conmon" ],
        state = None Text,
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    },
      when = Some [ "conmon_apt_version_ok" ]
    }
]
