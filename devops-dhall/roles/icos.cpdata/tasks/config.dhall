-- Auto-generated from config.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create application.conf",
      copy = Some {
        src = None Text
      , dest = "{{ cpdata_home }}/application.conf"
      , mode = None Text
      , content = Some ''
        {% for item in cpdata_config_files %}
        # {{ item }}
        {{ lookup('template', item) }}

        {% endfor %}

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      register = Some "_config"
    }
  , Task::{
      name = Some "Start/restart service",
      systemd = Some {
        name = Some "cpdata.service"
      , state = Some "{{ 'restarted' if _jarfile.changed | default(false) or _config.changed else 'started' }}"
      , daemon_reload = None Bool
      , enabled = Some "True"
      , `daemon-reload` = Some "{{ 'yes' if _service.changed | default(false) else 'no' }}"
      , status = None Text
    }
    }
]
