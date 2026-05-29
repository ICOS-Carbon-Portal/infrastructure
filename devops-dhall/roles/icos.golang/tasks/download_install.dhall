-- Auto-generated from download_install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Fail if golang-go is apt-installed",
      `ansible.builtin.shell` = Some ''
      dpkg --get-selections golang-go | grep -vq '\binstall'

    '',
      changed_when = Some "False",
      register = Some "r",
      failed_when = Some "r.rc == 0"
    }
  , Task::{
      name = Some "We only support amd64 for now",
      `assert` = Some { that = [ "ansible_machine == \"x86_64\"" ], quiet = None Bool },
      changed_when = Some "False"
    }
  , Task::{
      name = Some "Download go binary",
      get_url = Some {
        url = "{{ golang_url }}"
      , dest = "/tmp"
      , force = None Text
      , mode = None Text
    },
      register = Some "_download"
    }
  , Task::{
      name = Some "Create golang directory",
      file = Some {
        path = Some "{{ golang_opt_dir }}"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Unarchive golang",
      unarchive = Some {
        src = "{{ _download.dest }}"
      , dest = "{{ golang_opt_dir }}"
      , remote_src = True
      , owner = None Text
      , group = None Text
      , include = None (List Text)
      , list_files = None Bool
      , extra_opts = None (List Text)
      , mode = None Text
      , creates = None Text
    },
      diff = Some False
    }
  , Task::{
      name = Some "Create symlinks for go binaries",
      file = Some {
        path = None Text
      , state = Some "link"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = Some "/usr/local/bin/{{ item }}"
      , recurse = None Bool
      , src = Some "{{ golang_bin_dir }}/{{ item }}"
    },
      loop = Some [ "go", "gofmt" ]
    }
]
