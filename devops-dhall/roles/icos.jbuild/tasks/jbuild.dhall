-- Auto-generated from jbuild.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Remove virtual env",
      file = Some {
        path = Some "/opt/jbuild/venv"
      , state = Some "absent"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    },
      when = Some [ "virtualenv_recreate | default(False) | bool" ]
    }
  , Task::{
      name = Some "Create virtual env",
      pip = Some {
        name = [ "click", "GitPython", "docker" ]
      , virtualenv = Some "/opt/jbuild/venv"
      , state = Some "present"
    }
    }
  , Task::{
      name = Some "Copy jbuild.py",
      copy = Some {
        src = Some "jbuild.py"
      , dest = "/opt/jbuild/jbuild.py"
      , mode = Some "+x"
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = Some "{{ jbuild_force | default(True) | bool }}"
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Create /usr/local/sbin/jbuild symlink",
      file = Some {
        path = None Text
      , state = Some "link"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = Some "/usr/local/sbin/jbuild"
      , recurse = None Bool
      , src = Some "/opt/jbuild/jbuild.py"
    }
    }
  , Task::{
      name = Some "Check that jbuild executes",
      shell = Some "/usr/local/sbin/jbuild",
      changed_when = Some "False"
    }
]
