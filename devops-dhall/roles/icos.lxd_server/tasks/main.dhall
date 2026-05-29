-- Auto-generated from main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "sysctl.yml", tags = Some [ "lxd_sysctl" ] }
  , Task::{ import_tasks = Some "utils.yml", tags = Some [ "lxd_utils" ] }
  , Task::{
      name = Some "Retrieve lxd_is_snap fact",
      shellfact = Some {
        exec = "which lxc | grep -q '/snap/bin' && echo yes"
      , fact = "lxd_is_snap"
      , bool = Some True
      , list = None Bool
    }
    }
  , Task::{
      name = Some "Modify /etc/security/limits.conf",
      when = Some [ "not lxd_is_snap and not ansible_check_mode" ],
      tags = Some [ "lxd_limits" ],
      copy = Some {
        src = None Text
      , dest = "/etc/security/limits.conf"
      , mode = None Text
      , content = Some ''
        *    soft  nofile  1048576   unset   # max number of open files
        *    hard  nofile  1048576   unset   # max number of open files
        root soft  nofile  1048576   unset   # max number of open files
        root hard  nofile  1048576   unset   # max number of open files
        *    soft  memlock unlimited unset   # max locked-in-memory address space KB
        *    hard  memlock unlimited unset   # max locked-in-memory address space KB

      ''
      , backup = Some True
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
]
