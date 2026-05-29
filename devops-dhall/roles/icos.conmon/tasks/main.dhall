-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Retrieve version of installed conmon (if any)",
      check_mode = Some False,
      shellfact = Some {
        exec = ''
        for f in /usr/bin/conmon\
                 /usr/local/libexec/podman/conmon\
                 /usr/libexec/podman/conmon; do
          if [ -e $f ]; then
            $f --version | awk 'NR == 1 { print $3 }';
            break
          fi
        done

      ''
      , fact = "conmon_local_version"
      , bool = None Bool
      , list = None Bool
    }
    }
  , Task::{
      name = Some "Is installed version of conmon sufficient?",
      debug = Some { msg = "Version ({{ conmon_local_version }}) is sufficient" },
      when = Some [ "conmon_local_version_ok" ]
    }
  , Task::{ import_tasks = Some "apt_install.yml", when = Some [ "not conmon_local_version_ok" ] }
  , Task::{
      import_tasks = Some "download_install.yml",
      when = Some [ "not conmon_local_version_ok", "not conmon_apt_version_ok" ]
    }
]
