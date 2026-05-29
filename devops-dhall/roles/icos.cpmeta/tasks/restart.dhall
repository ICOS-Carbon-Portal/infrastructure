-- Auto-generated from restart.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create application.conf",
      copy = Some {
        src = None Text
      , dest = "{{ cpmeta_home }}/application.conf"
      , mode = None Text
      , content = Some ''
        {% for item in cpmeta_config_files %}
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
      name = Some "Temporarily switch cpmeta to readonly mode before restart",
      uri = Some {
        url = "http://127.0.0.1:{{ cpmeta_port }}/admin/switchToReadonlyMode"
      , return_content = None Bool
      , method = Some "POST"
      , user = None Text
      , password = None Text
    },
      failed_when = Some "False",
      when = Some [ "_restart_needed" ]
    }
  , Task::{
      name = Some "Start/restart service",
      systemd = Some {
        name = Some "cpmeta.service"
      , state = Some "{{ 'restarted' if _restart_needed else 'started' }}"
      , daemon_reload = None Bool
      , enabled = Some "True"
      , `daemon-reload` = None Text
      , status = None Text
    }
    }
  , Task::{
      name = Some "Check that the service responds",
      uri = Some {
        url = "https://{{ cpmeta_domains | first }}/buildInfo"
      , return_content = Some True
      , method = None Text
      , user = None Text
      , password = None Text
    },
      register = Some "r",
      failed_when = Some "r.failed",
      retries = Some 30,
      delay = Some 10,
      until = Some "not r.failed"
    }
  , Task::{
      name = Some "Leave cpmeta in readonly mode",
      uri = Some {
        url = "http://127.0.0.1:{{ cpmeta_port }}/admin/switchToReadonlyMode"
      , return_content = None Bool
      , method = Some "POST"
      , user = None Text
      , password = None Text
    },
      register = Some "r",
      failed_when = Some "r.failed",
      retries = Some 30,
      delay = Some 10,
      until = Some "not r.failed",
      when = Some [ "cpmeta_readonly_mode" ]
    }
]
