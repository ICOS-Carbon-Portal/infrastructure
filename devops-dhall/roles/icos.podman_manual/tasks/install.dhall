-- Auto-generated from install.yml

let Task =
    { Type =
        { name : Text
    , import_role : Optional ({ name : Text })
    , apt : Optional ({ name : List Text })
    , check_mode : Optional Bool
    , command : Optional Text
    , args : Optional ({ removes : Text })
    , changed_when : Optional Bool
    , git : Optional ({ repo : Text, version : Text, dest : Text })
    , diff : Optional Bool
    , make : Optional ({ chdir : Text, target : Text, params : Optional ({ BUILDTAGS : Text }) })
  }
    , default =
        { import_role = None ({ name : Text })
    , apt = None ({ name : List Text })
    , check_mode = None Bool
    , command = None Text
    , args = None ({ removes : Text })
    , changed_when = None Bool
    , git = None ({ repo : Text, version : Text, dest : Text })
    , diff = None Bool
    , make = None ({ chdir : Text, target : Text, params : Optional ({ BUILDTAGS : Text }) })
  }
    }

in  [
    Task::{ name = "Install golang", import_role = Some { name = "icos.golang" } }
  , Task::{
      name = "Install podman requirements",
      apt = Some {
        name = [
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
    }
    }
  , Task::{
      name = "Assert that user namespaces are available",
      check_mode = Some False,
      command = Some "grep -q CONFIG_USER_NS=y /boot/config-{{ ansible_kernel }}",
      args = Some { removes = "/boot/config-{{ ansible_kernel }}" },
      changed_when = Some False
    }
  , Task::{
      name = "Clone podman",
      git = Some {
        repo = "https://github.com/containers/podman"
      , version = "v{{ podman_version }}"
      , dest = "{{ podman_src_dir }}"
    },
      diff = Some False
    }
  , Task::{
      name = "Build podman",
      make = Some {
        chdir = "{{ podman_src_dir }}"
      , target = "default"
      , params = Some { BUILDTAGS = "seccomp selinux systemd" }
    }
    }
  , Task::{
      name = "Install podman",
      make = Some {
        chdir = "{{ podman_src_dir }}"
      , target = "install"
      , params = None ({ BUILDTAGS : Text })
    }
    }
]
