-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , check_mode : Optional Bool
    , shellfact : Optional ({ exec : Text, fact : Text })
    , debug : Optional ({ msg : Text })
    , when : Optional (List Text)
    , import_tasks : Optional Text
  }
    , default =
        { name = None Text
    , check_mode = None Bool
    , shellfact = None ({ exec : Text, fact : Text })
    , debug = None ({ msg : Text })
    , when = None (List Text)
    , import_tasks = None Text
  }
    }

in  [
    Item::{
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
    }
    }
  , Item::{
      name = Some "Is installed version of conmon sufficient?",
      debug = Some { msg = "Version ({{ conmon_local_version }}) is sufficient" },
      when = Some [ "conmon_local_version_ok" ]
    }
  , Item::{ when = Some [ "not conmon_local_version_ok" ], import_tasks = Some "apt_install.yml" }
  , Item::{
      when = Some [ "not conmon_local_version_ok", "not conmon_apt_version_ok" ],
      import_tasks = Some "download_install.yml"
    }
]
