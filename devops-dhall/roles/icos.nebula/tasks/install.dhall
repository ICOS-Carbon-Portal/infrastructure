-- Auto-generated from install.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : List Text })
    , user : Optional ({ name : Text, shell : Text, system : Bool, create_home : Bool })
    , file : Optional ({ path : Text, owner : Text, group : Text, state : Text, mode : Natural })
    , stat : Optional ({ path : Text })
    , register : Optional Text
    , include_tasks : Optional Text
    , when : Optional Text
    , shell : Optional Text
    , changed_when : Optional Bool
    , loop : Optional (List Text)
    , run_once : Optional Bool
    , debug : Optional ({ msg : Text })
  }
    , default =
        { apt = None ({ name : List Text })
    , user = None ({ name : Text, shell : Text, system : Bool, create_home : Bool })
    , file = None ({ path : Text, owner : Text, group : Text, state : Text, mode : Natural })
    , stat = None ({ path : Text })
    , register = None Text
    , include_tasks = None Text
    , when = None Text
    , shell = None Text
    , changed_when = None Bool
    , loop = None (List Text)
    , run_once = None Bool
    , debug = None ({ msg : Text })
  }
    }

in  [
    Task::{ name = "Install packages", apt = Some { name = [ "jq" ] } }
  , Task::{
      name = "Create nebula user",
      user = Some {
        name = "{{ nebula_user }}"
      , shell = "/usr/sbin/nologin"
      , system = True
      , create_home = False
    }
    }
  , Task::{
      name = "Create etc directory",
      file = Some {
        path = "{{ nebula_etc_dir }}"
      , owner = "{{ nebula_user }}"
      , group = "{{ nebula_user }}"
      , state = "directory"
      , mode = 448
    }
    }
  , Task::{
      name = "Check whether nebula is already installed",
      stat = Some { path = "{{ nebula_bin_dir }}/nebula" },
      register = Some "_r"
    }
  , Task::{
      name = "Download and unpack nebula",
      include_tasks = Some "download.yml",
      when = Some "not _r.stat.exists or nebula_upgrade"
    }
  , Task::{
      name = "Check that nebula runs",
      register = Some "version",
      shell = Some ''
      {{ nebula_bin_dir }}/{{ item }} -version

    '',
      changed_when = Some False,
      loop = Some [ "nebula", "nebula-cert" ]
    }
  , Task::{
      name = "Inform about installed version",
      when = Some "not ansible_check_mode",
      run_once = Some True,
      debug = Some {
        msg = ''
        We've installed nebula {{ version.results[0].stdout_lines[0] }}

      ''
    }
    }
]
