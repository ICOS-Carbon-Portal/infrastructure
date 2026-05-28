-- Auto-generated from restart.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ dest : Text, content : Text })
    , register : Optional Text
    , uri : Optional ({ method : Optional Text, url : Text, return_content : Optional Bool })
    , failed_when : Optional Text
    , when : Optional Text
    , systemd : Optional ({ name : Text, enabled : Bool, state : Text })
    , retries : Optional Natural
    , delay : Optional Natural
    , until : Optional Text
  }
    , default =
        { copy = None ({ dest : Text, content : Text })
    , register = None Text
    , uri = None ({ method : Optional Text, url : Text, return_content : Optional Bool })
    , failed_when = None Text
    , when = None Text
    , systemd = None ({ name : Text, enabled : Bool, state : Text })
    , retries = None Natural
    , delay = None Natural
    , until = None Text
  }
    }

in  [
    Task::{
      name = "Create application.conf",
      copy = Some {
        dest = "{{ cpmeta_home }}/application.conf"
      , content = ''
        {% for item in cpmeta_config_files %}
        # {{ item }}
        {{ lookup('template', item) }}

        {% endfor %}

      ''
    },
      register = Some "_config"
    }
  , Task::{
      name = "Temporarily switch cpmeta to readonly mode before restart",
      uri = Some {
        method = Some "POST"
      , url = "http://127.0.0.1:{{ cpmeta_port }}/admin/switchToReadonlyMode"
      , return_content = None Bool
    },
      failed_when = Some "False",
      when = Some "_restart_needed"
    }
  , Task::{
      name = "Start/restart service",
      systemd = Some {
        name = "cpmeta.service"
      , enabled = True
      , state = "{{ 'restarted' if _restart_needed else 'started' }}"
    }
    }
  , Task::{
      name = "Check that the service responds",
      register = Some "r",
      uri = Some {
        method = None Text
      , url = "https://{{ cpmeta_domains | first }}/buildInfo"
      , return_content = Some True
    },
      failed_when = Some "r.failed",
      retries = Some 30,
      delay = Some 10,
      until = Some "not r.failed"
    }
  , Task::{
      name = "Leave cpmeta in readonly mode",
      register = Some "r",
      uri = Some {
        method = Some "POST"
      , url = "http://127.0.0.1:{{ cpmeta_port }}/admin/switchToReadonlyMode"
      , return_content = None Bool
    },
      failed_when = Some "r.failed",
      when = Some "cpmeta_readonly_mode",
      retries = Some 30,
      delay = Some 10,
      until = Some "not r.failed"
    }
]
