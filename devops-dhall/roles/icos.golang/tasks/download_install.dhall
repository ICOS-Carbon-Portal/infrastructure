-- Auto-generated from download_install.yml

let Entry =
    { Type =
        { name : Text
    , `ansible.builtin.shell` : Optional Text
    , changed_when : Optional Bool
    , register : Optional Text
    , failed_when : Optional Text
    , `assert` : Optional ({ that : Text })
    , get_url : Optional ({ url : Text, dest : Text })
    , file : Optional ({ path : Optional Text, state : Text, dest : Optional Text, src : Optional Text })
    , unarchive : Optional ({ src : Text, dest : Text, remote_src : Bool })
    , diff : Optional Bool
    , loop : Optional (List Text)
  }
    , default =
        { `ansible.builtin.shell` = None Text
    , changed_when = None Bool
    , register = None Text
    , failed_when = None Text
    , `assert` = None ({ that : Text })
    , get_url = None ({ url : Text, dest : Text })
    , file = None ({ path : Optional Text, state : Text, dest : Optional Text, src : Optional Text })
    , unarchive = None ({ src : Text, dest : Text, remote_src : Bool })
    , diff = None Bool
    , loop = None (List Text)
  }
    }

in  [
    Entry::{
      name = "Fail if golang-go is apt-installed",
      `ansible.builtin.shell` = Some ''
      dpkg --get-selections golang-go | grep -vq '\binstall'

    '',
      changed_when = Some False,
      register = Some "r",
      failed_when = Some "r.rc == 0"
    }
  , Entry::{
      name = "We only support amd64 for now",
      changed_when = Some False,
      `assert` = Some { that = "ansible_machine == \"x86_64\"" }
    }
  , Entry::{
      name = "Download go binary",
      register = Some "_download",
      get_url = Some { url = "{{ golang_url }}", dest = "/tmp" }
    }
  , Entry::{
      name = "Create golang directory",
      file = Some {
        path = Some "{{ golang_opt_dir }}"
      , state = "directory"
      , dest = None Text
      , src = None Text
    }
    }
  , Entry::{
      name = "Unarchive golang",
      unarchive = Some { src = "{{ _download.dest }}", dest = "{{ golang_opt_dir }}", remote_src = True },
      diff = Some False
    }
  , Entry::{
      name = "Create symlinks for go binaries",
      file = Some {
        path = None Text
      , state = "link"
      , dest = Some "/usr/local/bin/{{ item }}"
      , src = Some "{{ golang_bin_dir }}/{{ item }}"
    },
      loop = Some [ "go", "gofmt" ]
    }
]
