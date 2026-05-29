-- Auto-generated from add_fsd.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{ import_tasks = Some "assert_installed.yml" }
  , Task::{
      name = Some "Check that the metrics endpoint responds",
      uri = Some {
        url = "http://{{ fsd_target }}/{{ fsd_path | default('/metrics') }}"
      , return_content = None Bool
      , method = None Text
      , user = None Text
      , password = None Text
    },
      retries = Some 3
    }
  , Task::{
      name = Some "Install scrape config",
      copy = Some {
        src = None Text
      , dest = "{{ vmagent_fsd }}/{{ fsd_name }}.yaml"
      , mode = None Text
      , content = Some ''
        # {{ fsd_name }}
        - targets:
          - {{ fsd_target }}
          labels:
            {% if fsd_path is defined %}
            __metrics_path__: "{{ fsd_path }}"
            {%- endif %}
            host: {{ fsd_host }}

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
]
