-- Auto-generated from install.yml

let Entry =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, mode : Text, state : Text })
    , loop : Optional (List ({ path : Text, mode : Optional Text }))
    , stat : Optional ({ path : Text })
    , register : Optional Text
    , import_tasks : Optional Text
    , when : Optional Text
  }
    , default =
        { file = None ({ path : Text, mode : Text, state : Text })
    , loop = None (List ({ path : Text, mode : Optional Text }))
    , stat = None ({ path : Text })
    , register = None Text
    , import_tasks = None Text
    , when = None Text
  }
    }

in  [
    Entry::{
      name = "Create vmagent directories",
      file = Some {
        path = "{{ item.path }}"
      , mode = "{{ item.mode | default(omit) }}"
      , state = "directory"
    },
      loop = Some [
        { path = "{{ vmagent_home }}", mode = Some "0700" }
      , { path = "{{ vmagent_bin }}", mode = None Text }
      , { path = "{{ vmagent_fsd }}", mode = None Text }
      , { path = "{{ vmagent_configs }}", mode = None Text }
    ]
    }
  , Entry::{
      name = "Check whether vmagent is installed",
      stat = Some { path = "{{ vmagent_bin }}/vmagent-prod" },
      register = Some "_vmagent"
    }
  , Entry::{
      name = "Install/upgrade install vmagent",
      import_tasks = Some "really_install.yml",
      when = Some "not _vmagent.stat.exists or (vmagent_upgrade | default(False) | bool)"
    }
]
