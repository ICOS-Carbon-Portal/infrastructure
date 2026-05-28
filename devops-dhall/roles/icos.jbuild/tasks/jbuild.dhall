-- Auto-generated from jbuild.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Optional Text, state : Text, dest : Optional Text, src : Optional Text })
    , when : Optional Text
    , pip : Optional ({ virtualenv : Text, name : List Text, state : Text })
    , copy : Optional ({ src : Text, dest : Text, mode : Text, force : Text })
    , shell : Optional Text
    , changed_when : Optional Bool
  }
    , default =
        { file = None ({ path : Optional Text, state : Text, dest : Optional Text, src : Optional Text })
    , when = None Text
    , pip = None ({ virtualenv : Text, name : List Text, state : Text })
    , copy = None ({ src : Text, dest : Text, mode : Text, force : Text })
    , shell = None Text
    , changed_when = None Bool
  }
    }

in  [
    Task::{
      name = "Remove virtual env",
      file = Some {
        path = Some "/opt/jbuild/venv"
      , state = "absent"
      , dest = None Text
      , src = None Text
    },
      when = Some "virtualenv_recreate | default(False) | bool"
    }
  , Task::{
      name = "Create virtual env",
      pip = Some {
        virtualenv = "/opt/jbuild/venv"
      , name = [ "click", "GitPython", "docker" ]
      , state = "present"
    }
    }
  , Task::{
      name = "Copy jbuild.py",
      copy = Some {
        src = "jbuild.py"
      , dest = "/opt/jbuild/jbuild.py"
      , mode = "+x"
      , force = "{{ jbuild_force | default(True) | bool }}"
    }
    }
  , Task::{
      name = "Create /usr/local/sbin/jbuild symlink",
      file = Some {
        path = None Text
      , state = "link"
      , dest = Some "/usr/local/sbin/jbuild"
      , src = Some "/opt/jbuild/jbuild.py"
    }
    }
  , Task::{
      name = "Check that jbuild executes",
      shell = Some "/usr/local/sbin/jbuild",
      changed_when = Some False
    }
]
