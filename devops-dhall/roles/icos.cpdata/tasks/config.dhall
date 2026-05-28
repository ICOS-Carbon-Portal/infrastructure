-- Auto-generated from config.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ dest : Text, content : Text })
    , register : Optional Text
    , systemd : Optional ({ name : Text, enabled : Bool, `daemon-reload` : Text, state : Text })
  }
    , default =
        { copy = None ({ dest : Text, content : Text })
    , register = None Text
    , systemd = None ({ name : Text, enabled : Bool, `daemon-reload` : Text, state : Text })
  }
    }

in  [
    Task::{
      name = "Create application.conf",
      copy = Some {
        dest = "{{ cpdata_home }}/application.conf"
      , content = ''
        {% for item in cpdata_config_files %}
        # {{ item }}
        {{ lookup('template', item) }}

        {% endfor %}

      ''
    },
      register = Some "_config"
    }
  , Task::{
      name = "Start/restart service",
      systemd = Some {
        name = "cpdata.service"
      , enabled = True
      , `daemon-reload` = "{{ 'yes' if _service.changed | default(false) else 'no' }}"
      , state = "{{ 'restarted' if _jarfile.changed | default(false) or _config.changed else 'started' }}"
    }
    }
]
