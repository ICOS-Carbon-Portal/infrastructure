-- Auto-generated from add_config.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "assert_installed.yml" }
  , Task::{
      name = Some "Add a vmagent scrape config",
      copy = Some {
        src = None Text
      , dest = "{{ vmagent_configs }}/{{ vmagent_config_dest }}"
      , mode = None Text
      , content = Some "{{ vmagent_config_content }}"
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      notify = Some [ "reload vmagent" ]
    }
]
