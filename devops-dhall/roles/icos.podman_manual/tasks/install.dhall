-- Auto-generated from install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ name = Some "Install golang", import_role = Some { name = "icos.golang" } }
  , Task::{
      name = Some "Install podman requirements",
      apt = Some {
        name = Some [
          "btrfs-progs"
        , "git"
        , "go-md2man"
        , "iptables"
        , "libassuan-dev"
        , "libbtrfs-dev"
        , "libc6-dev"
        , "libdevmapper-dev"
        , "libglib2.0-dev"
        , "libgpgme-dev"
        , "libgpg-error-dev"
        , "libprotobuf-dev"
        , "libprotobuf-c-dev"
        , "libseccomp-dev"
        , "libselinux1-dev"
        , "libsystemd-dev"
        , "pkg-config"
        , "crun"
        , "uidmap"
        , "slirp4netns"
      ]
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
  , Task::{
      name = Some "Assert that user namespaces are available",
      check_mode = Some False,
      command = Some "grep -q CONFIG_USER_NS=y /boot/config-{{ ansible_kernel }}",
      args = Some {
        creates = None Text
      , chdir = None Text
      , executable = None Text
      , removes = Some "/boot/config-{{ ansible_kernel }}"
    },
      changed_when = Some "False"
    }
  , Task::{
      name = Some "Clone podman",
      git = Some {
        repo = "https://github.com/containers/podman"
      , version = Some "v{{ podman_version }}"
      , dest = "{{ podman_src_dir }}"
      , force = None Bool
      , update = None Text
      , key_file = None Text
    },
      diff = Some False
    }
  , Task::{
      name = Some "Build podman",
      make = Some {
        chdir = "{{ podman_src_dir }}"
      , target = "default"
      , params = Some { BUILDTAGS = "seccomp selinux systemd" }
    }
    }
  , Task::{
      name = Some "Install podman",
      make = Some {
        chdir = "{{ podman_src_dir }}"
      , target = "install"
      , params = None ({ BUILDTAGS : Text })
    }
    }
]
