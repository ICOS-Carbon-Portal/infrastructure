-- Auto-generated from main.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , tags : Optional Text
    , name : Optional Text
    , shellfact : Optional ({ exec : Text, fact : Text, bool : Bool })
    , when : Optional Text
    , copy : Optional ({ dest : Text, backup : Bool, content : Text })
  }
    , default =
        { import_tasks = None Text
    , tags = None Text
    , name = None Text
    , shellfact = None ({ exec : Text, fact : Text, bool : Bool })
    , when = None Text
    , copy = None ({ dest : Text, backup : Bool, content : Text })
  }
    }

in  [
    Item::{ import_tasks = Some "sysctl.yml", tags = Some "lxd_sysctl" }
  , Item::{ import_tasks = Some "utils.yml", tags = Some "lxd_utils" }
  , Item::{
      name = Some "Retrieve lxd_is_snap fact",
      shellfact = Some {
        exec = "which lxc | grep -q '/snap/bin' && echo yes"
      , fact = "lxd_is_snap"
      , bool = True
    }
    }
  , Item::{
      tags = Some "lxd_limits",
      name = Some "Modify /etc/security/limits.conf",
      when = Some "not lxd_is_snap and not ansible_check_mode",
      copy = Some {
        dest = "/etc/security/limits.conf"
      , backup = True
      , content = ''
        *    soft  nofile  1048576   unset   # max number of open files
        *    hard  nofile  1048576   unset   # max number of open files
        root soft  nofile  1048576   unset   # max number of open files
        root hard  nofile  1048576   unset   # max number of open files
        *    soft  memlock unlimited unset   # max locked-in-memory address space KB
        *    hard  memlock unlimited unset   # max locked-in-memory address space KB

      ''
    }
    }
]
