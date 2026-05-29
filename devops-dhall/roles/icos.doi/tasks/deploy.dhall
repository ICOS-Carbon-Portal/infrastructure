-- Auto-generated from deploy.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add systemd service",
      template = Some {
        src = "doi.service"
      , dest = "/etc/systemd/system/doi.service"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      register = Some "_service"
    }
  , Task::{
      name = Some "Create application.conf",
      template = Some {
        src = "application.conf"
      , dest = "{{ doi_home }}/application.conf"
      , mode = None Text
      , variable_start_string = None Text
      , variable_end_string = None Text
      , lstrip_blocks = None Bool
      , validate = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
    },
      register = Some "_config"
    }
  , Task::{
      name = Some "Copy jarfile",
      copy = Some {
        src = Some "{{ doi_jar_file }}"
      , dest = "{{ doi_home }}/doi.jar"
      , mode = None Text
      , content = None Text
      , backup = Some True
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    },
      register = Some "_jarfile"
    }
  , Task::{
      name = Some "Remove all but the five newest of jar file backups",
      `ansible.builtin.shell` = Some ''
      ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --

    '',
      args = Some {
        creates = None Text
      , chdir = Some "{{ doi_home }}"
      , executable = None Text
      , removes = None Text
    },
      register = Some "_r",
      changed_when = Some "_r.stdout.startswith(\"removed\")"
    }
  , Task::{
      name = Some "Start/restart service",
      systemd = Some {
        name = Some "doi.service"
      , state = Some "{{ 'restarted' if _jarfile.changed or _config.changed else 'started' }}"
      , daemon_reload = None Bool
      , enabled = Some "True"
      , `daemon-reload` = Some "{{ 'yes' if _service.changed else 'no' }}"
      , status = None Text
    }
    }
  , Task::{
      name = Some "Check that the service responds",
      uri = Some {
        url = "https://{{ doi_domains | first }}/buildInfo"
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
]
