-- Auto-generated from add_fsd.yml

let Item =
    { Type =
        { import_tasks : Optional Text
    , name : Optional Text
    , uri : Optional ({ url : Text })
    , retries : Optional Natural
    , copy : Optional ({ dest : Text, content : Text })
  }
    , default =
        { import_tasks = None Text
    , name = None Text
    , uri = None ({ url : Text })
    , retries = None Natural
    , copy = None ({ dest : Text, content : Text })
  }
    }

in  [
    Item::{ import_tasks = Some "assert_installed.yml" }
  , Item::{
      name = Some "Check that the metrics endpoint responds",
      uri = Some { url = "http://{{ fsd_target }}/{{ fsd_path | default('/metrics') }}" },
      retries = Some 3
    }
  , Item::{
      name = Some "Install scrape config",
      copy = Some {
        dest = "{{ vmagent_fsd }}/{{ fsd_name }}.yaml"
      , content = ''
        # {{ fsd_name }}
        - targets:
          - {{ fsd_target }}
          labels:
            {% if fsd_path is defined %}
            __metrics_path__: "{{ fsd_path }}"
            {%- endif %}
            host: {{ fsd_host }}

      ''
    }
    }
]
