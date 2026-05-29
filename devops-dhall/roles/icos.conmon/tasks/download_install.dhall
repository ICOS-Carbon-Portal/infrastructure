-- Auto-generated from ../../../../devops/roles/icos.conmon/tasks/download_install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Fail if conmon is apt-installed",
      `ansible.builtin.shell` = Some (Task.Poly_ansible_builtin_shell.Str ''
        dpkg --get-selections conmon | grep -vq '\binstall'

      ''),
      changed_when = Some (Task.Poly_changed_when.Bool False),
      register = Some "r",
      failed_when = Some (Task.Poly_failed_when.Str "r.rc == 0")
    }
  , Task::{
      name = Some "Install packages needed to compile conmon",
      apt = Some {
        name = Some [
          "gcc"
        , "git"
        , "libc6-dev"
        , "libglib2.0-dev"
        , "libseccomp-dev"
        , "pkg-config"
        , "make"
        , "crun"
      ],
        state = None Text,
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Download conmon sources",
      get_url = Some { url = "{{ conmon_url }}", dest = "/tmp", force = None Text, mode = None Text },
      register = Some "_download"
    }
  , Task::{
      name = Some "Unarchive sources",
      unarchive = Some {
        src = "{{ _download.dest }}",
        dest = "/tmp",
        remote_src = True,
        owner = None Text,
        group = None Text,
        include = None ((List Text)),
        list_files = None Bool,
        extra_opts = None ((List Text)),
        mode = None Text,
        creates = None Text
    },
      diff = Some False
    }
  , Task::{
      name = Some "Build conmon",
      make = Some {
        chdir = "/tmp/conmon-{{ conmon_version_install }}",
        target = "podman",
        params = None (({ BUILDTAGS : Text }))
    }
    }
]
