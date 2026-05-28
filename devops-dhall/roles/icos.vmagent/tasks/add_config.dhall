-- Auto-generated from add_config.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , name : Optional Text
    , copy : Optional ({ dest : Text, content : Text })
    , notify : Optional Text
  }
    , default =
        { import_tasks = None Text
    , name = None Text
    , copy = None ({ dest : Text, content : Text })
    , notify = None Text
  }
    }

in  [
    Item::{ import_tasks = Some "assert_installed.yml" }
  , Item::{
      name = Some "Add a vmagent scrape config",
      copy = Some {
        dest = "{{ vmagent_configs }}/{{ vmagent_config_dest }}"
      , content = "{{ vmagent_config_content }}"
    },
      notify = Some "reload vmagent"
    }
]
