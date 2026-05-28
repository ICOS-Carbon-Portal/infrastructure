-- Auto-generated from deploy.yml

let Task =
    { Type =
        { name : Text
    , template : Optional ({ src : Text, dest : Text })
    , register : Optional Text
    , copy : Optional ({ dest : Text, content : Optional Text, src : Optional Text, backup : Optional Bool })
    , `ansible.builtin.shell` : Optional Text
    , args : Optional ({ chdir : Text })
    , changed_when : Optional Text
    , systemd : Optional ({ name : Text, enabled : Bool, `daemon-reload` : Text, state : Text })
    , uri : Optional ({ url : Text, return_content : Bool })
    , failed_when : Optional Text
    , retries : Optional Natural
    , delay : Optional Natural
    , until : Optional Text
  }
    , default =
        { template = None ({ src : Text, dest : Text })
    , register = None Text
    , copy = None ({ dest : Text, content : Optional Text, src : Optional Text, backup : Optional Bool })
    , `ansible.builtin.shell` = None Text
    , args = None ({ chdir : Text })
    , changed_when = None Text
    , systemd = None ({ name : Text, enabled : Bool, `daemon-reload` : Text, state : Text })
    , uri = None ({ url : Text, return_content : Bool })
    , failed_when = None Text
    , retries = None Natural
    , delay = None Natural
    , until = None Text
  }
    }

in  [
    Task::{
      name = "Add systemd service",
      template = Some { src = "cpauth.service", dest = "/etc/systemd/system/cpauth.service" },
      register = Some "_service"
    }
  , Task::{
      name = "Create application.conf",
      register = Some "_config",
      copy = Some {
        dest = "{{ cpauth_home }}/application.conf"
      , content = Some ''
        {% for item in cpauth_config_files %}
        # {{ item }}
        {{ lookup('template', item) }}

        {% endfor %}

      ''
      , src = None Text
      , backup = None Bool
    }
    }
  , Task::{
      name = "Copy jarfile",
      register = Some "_jarfile",
      copy = Some {
        dest = "{{ cpauth_home }}/cpauth.jar"
      , content = None Text
      , src = Some "{{ cpauth_jar_file }}"
      , backup = Some True
    }
    }
  , Task::{
      name = "Remove all but the five newest of jar file backups",
      register = Some "_r",
      `ansible.builtin.shell` = Some ''
      ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --

    '',
      args = Some { chdir = "{{ cpauth_home }}" },
      changed_when = Some "_r.stdout.startswith(\"removed\")"
    }
  , Task::{
      name = "Start/restart service",
      systemd = Some {
        name = "cpauth.service"
      , enabled = True
      , `daemon-reload` = "{{ 'yes' if _service.changed else 'no' }}"
      , state = "{{ 'restarted' if _jarfile.changed or _config.changed else 'started' }}"
    }
    }
  , Task::{
      name = "Check that the service responds",
      register = Some "r",
      uri = Some { url = "https://{{ cpauth_domains | first }}/buildInfo", return_content = True },
      failed_when = Some "r.failed",
      retries = Some 30,
      delay = Some 10,
      until = Some "not r.failed"
    }
]
