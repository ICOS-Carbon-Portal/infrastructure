-- Auto-generated from download_install.yml

let Task =
    { Type =
        { name : Text
    , `ansible.builtin.shell` : Optional Text
    , changed_when : Optional Bool
    , register : Optional Text
    , failed_when : Optional Text
    , apt : Optional ({ name : List Text })
    , get_url : Optional ({ url : Text, dest : Text })
    , unarchive : Optional ({ src : Text, dest : Text, remote_src : Bool })
    , diff : Optional Bool
    , make : Optional ({ chdir : Text, target : Text })
  }
    , default =
        { `ansible.builtin.shell` = None Text
    , changed_when = None Bool
    , register = None Text
    , failed_when = None Text
    , apt = None ({ name : List Text })
    , get_url = None ({ url : Text, dest : Text })
    , unarchive = None ({ src : Text, dest : Text, remote_src : Bool })
    , diff = None Bool
    , make = None ({ chdir : Text, target : Text })
  }
    }

in  [
    Task::{
      name = "Fail if conmon is apt-installed",
      `ansible.builtin.shell` = Some ''
      dpkg --get-selections conmon | grep -vq '\binstall'

    '',
      changed_when = Some False,
      register = Some "r",
      failed_when = Some "r.rc == 0"
    }
  , Task::{
      name = "Install packages needed to compile conmon",
      apt = Some {
        name = [
          "gcc"
        , "git"
        , "libc6-dev"
        , "libglib2.0-dev"
        , "libseccomp-dev"
        , "pkg-config"
        , "make"
        , "crun"
      ]
    }
    }
  , Task::{
      name = "Download conmon sources",
      register = Some "_download",
      get_url = Some { url = "{{ conmon_url }}", dest = "/tmp" }
    }
  , Task::{
      name = "Unarchive sources",
      unarchive = Some { src = "{{ _download.dest }}", dest = "/tmp", remote_src = True },
      diff = Some False
    }
  , Task::{
      name = "Build conmon",
      make = Some { chdir = "/tmp/conmon-{{ conmon_version_install }}", target = "podman" }
    }
]
