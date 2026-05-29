-- Auto-generated from install.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install wireguard for modern kernels",
      include_tasks = Some "wireguard-ubuntu.yml",
      when = Some [ "ansible_kernel is version('5.6', '>=')" ]
    }
  , Task::{
      name = Some "Include install tasks for raspbian",
      include_tasks = Some "wireguard-raspbian-zero.yml",
      when = Some [
        "not _wg_is_installed"
      , "ansible_distribution == \"Debian\""
      , "ansible_lsb.id == \"Raspbian\""
      , "ansible_machine == \"armv6l\""
    ]
    }
  , Task::{
      name = Some "Include install tasks for raspbian",
      include_tasks = Some "wireguard-raspbian.yml",
      when = Some [
        "not _wg_is_installed"
      , "ansible_distribution == \"Debian\""
      , "ansible_lsb.id == \"Raspbian\""
      , "ansible_machine != \"armv6l\""
    ]
    }
  , Task::{
      name = Some "Include install tasks for ubuntu",
      include_tasks = Some "wireguard-ubuntu.yml",
      when = Some [ "not _wg_is_installed", "ansible_distribution == \"Ubuntu\"" ]
    }
  , Task::{
      name = Some "Fail if wireguard wasn't installed",
      fail = Some {
        msg = "Couldn't install wireguard for {{ ansible_distribution }}/{{ ansible_lsb.id }}"
    },
      when = Some [ "not _wg_is_installed" ]
    }
]
