-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , command : Optional Text
    , failed_when : Optional Text
    , changed_when : Optional Bool
    , register : Optional Text
    , `ansible.builtin.shell` : Optional Text
    , check_mode : Optional Bool
    , import_tasks : Optional Text
    , tags : Optional Text
    , when : Optional Text
    , block : Optional (List ({ debug : Optional ({ msg : Text }), when : Optional Text, import_tasks : Optional Text, tags : Optional Text }))
    , import_role : Optional ({ name : Text })
    , apt : Optional ({ name : Text })
  }
    , default =
        { name = None Text
    , command = None Text
    , failed_when = None Text
    , changed_when = None Bool
    , register = None Text
    , `ansible.builtin.shell` = None Text
    , check_mode = None Bool
    , import_tasks = None Text
    , tags = None Text
    , when = None Text
    , block = None (List ({ debug : Optional ({ msg : Text }), when : Optional Text, import_tasks : Optional Text, tags : Optional Text }))
    , import_role = None ({ name : Text })
    , apt = None ({ name : Text })
  }
    }

in  [
    Item::{
      name = Some "Check whether podman is dpkg-installed",
      command = Some "dpkg -s podman",
      failed_when = Some "False",
      changed_when = Some False,
      register = Some "_dpkg"
    }
  , Item::{
      name = Some "Fail if podman is apt-installed",
      failed_when = Some "r.rc == 0",
      changed_when = Some False,
      register = Some "r",
      `ansible.builtin.shell` = Some ''
      dpkg --get-selections podman | grep -vq '\binstall'

    ''
    }
  , Item::{
      name = Some "Checking for version of installed podman",
      command = Some "podman --version",
      failed_when = Some "False",
      changed_when = Some False,
      register = Some "_podman",
      check_mode = Some False
    }
  , Item::{
      name = Some "Installing podman",
      import_tasks = Some "install.yml",
      tags = Some "podman_install",
      when = Some "not _podman.stdout.endswith(podman_version)"
    }
  , Item::{
      name = Some "Podman is installed and the correct version.",
      when = Some "_podman is undefined or _podman.stdout.endswith(podman_version)",
      block = Some [
        {
          debug = Some { msg = "The correct version of podman is installed." },
          when = Some "_podman is undefined",
          import_tasks = None Text,
          tags = None Text
        }
      , {
          debug = None ({ msg : Text }),
          when = None Text,
          import_tasks = Some "configure.yml",
          tags = Some "podman_configure"
        }
    ]
    }
  , Item::{
      name = Some "Install conmon",
      tags = Some "podman_conmon",
      import_role = Some { name = "icos.conmon" }
    }
  , Item::{
      name = Some "Install cni_plugins",
      tags = Some "podman_cni_plugins",
      import_role = Some { name = "icos.cni_plugins" }
    }
  , Item::{ name = Some "Install containers-storage", apt = Some { name = "containers-storage" } }
  , Item::{
      name = Some "Emulate docker",
      import_tasks = Some "docker.yml",
      tags = Some "podman_docker",
      when = Some "podman_docker"
    }
  , Item::{ tags = Some "podman_utils", import_role = Some { name = "icos.docker_utils" } }
]
