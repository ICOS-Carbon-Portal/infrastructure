-- Auto-generated from install.yml

let Entry =
    { Type =
        { name : Text
    , include_tasks : Optional Text
    , when : List Text
    , fail : Optional ({ msg : Text })
  }
    , default =
        { include_tasks = None Text
    , fail = None ({ msg : Text })
  }
    }

in  [
    Entry::{
      name = "Install wireguard for modern kernels",
      include_tasks = Some "wireguard-ubuntu.yml",
      when = [ "ansible_kernel is version('5.6', '>=')" ]
    }
  , Entry::{
      name = "Include install tasks for raspbian",
      include_tasks = Some "wireguard-raspbian-zero.yml",
      when = [
        "not _wg_is_installed"
      , "ansible_distribution == \"Debian\""
      , "ansible_lsb.id == \"Raspbian\""
      , "ansible_machine == \"armv6l\""
    ]
    }
  , Entry::{
      name = "Include install tasks for raspbian",
      include_tasks = Some "wireguard-raspbian.yml",
      when = [
        "not _wg_is_installed"
      , "ansible_distribution == \"Debian\""
      , "ansible_lsb.id == \"Raspbian\""
      , "ansible_machine != \"armv6l\""
    ]
    }
  , Entry::{
      name = "Include install tasks for ubuntu",
      include_tasks = Some "wireguard-ubuntu.yml",
      when = [ "not _wg_is_installed", "ansible_distribution == \"Ubuntu\"" ]
    }
  , Entry::{
      name = "Fail if wireguard wasn't installed",
      when = [ "not _wg_is_installed" ],
      fail = Some {
        msg = "Couldn't install wireguard for {{ ansible_distribution }}/{{ ansible_lsb.id }}"
    }
    }
]
