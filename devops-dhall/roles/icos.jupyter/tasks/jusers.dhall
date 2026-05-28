-- Auto-generated from jusers.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Optional Text, state : Text, dest : Optional Text, src : Optional Text })
    , when : Optional Text
    , pip : Optional ({ virtualenv : Text, name : List Text, state : Text })
    , template : Optional ({ src : Text, dest : Text, mode : Text, backup : Bool })
    , copy : Optional ({ src : Text, dest : Text, backup : Optional Bool })
    , shell : Optional Text
    , changed_when : Optional Bool
  }
    , default =
        { file = None ({ path : Optional Text, state : Text, dest : Optional Text, src : Optional Text })
    , when = None Text
    , pip = None ({ virtualenv : Text, name : List Text, state : Text })
    , template = None ({ src : Text, dest : Text, mode : Text, backup : Bool })
    , copy = None ({ src : Text, dest : Text, backup : Optional Bool })
    , shell = None Text
    , changed_when = None Bool
  }
    }

in  [
    Task::{
      name = "Remove virtual env",
      file = Some {
        path = Some "{{ jusers_venv }}"
      , state = "absent"
      , dest = None Text
      , src = None Text
    },
      when = Some "virtualenv_recreate | default(False) | bool"
    }
  , Task::{
      name = "Create virtual env",
      pip = Some {
        virtualenv = "{{ jusers_venv }}"
      , name = [ "ruamel.yaml", "click", "pandas", "requests" ]
      , state = "present"
    }
    }
  , Task::{
      name = "Copy jusers.py",
      template = Some {
        src = "jusers.py"
      , dest = "{{ jusers_home }}/jusers.py"
      , mode = "+x"
      , backup = True
    }
    }
  , Task::{
      name = "Copy plugins",
      copy = Some { src = "plugins", dest = "{{ jusers_home }}/", backup = None Bool }
    }
  , Task::{
      name = "Copy readme_template.html",
      copy = Some {
        src = "readme_template.html"
      , dest = "/root/readme_template.html"
      , backup = Some True
    }
    }
  , Task::{
      name = "Create /usr/local/sbin/jusers symlink",
      file = Some {
        path = None Text
      , state = "link"
      , dest = Some "/usr/local/sbin/jusers"
      , src = Some "{{ jusers_home }}/jusers.py"
    }
    }
  , Task::{
      name = "Check that jusers executes",
      shell = Some "/usr/local/sbin/jusers",
      changed_when = Some False
    }
]
