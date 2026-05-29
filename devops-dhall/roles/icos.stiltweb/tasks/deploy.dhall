-- Auto-generated from ../../../../devops/roles/icos.stiltweb/tasks/deploy.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add systemd service",
      template = Some {
        src = "stiltweb.service",
        dest = "/etc/systemd/system/stiltweb.service",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      register = Some "_service"
    }
  , Task::{
      name = Some "Create configuration file",
      template = Some {
        src = "local.conf",
        dest = "{{ stiltweb_home }}/local.conf",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      register = Some "_config"
    }
  , Task::{
      name = Some "Copy jarfile",
      when = Some [ "stiltweb_jar_file is defined" ],
      copy = Some {
        dest = "{{ stiltweb_home }}/stiltweb.jar",
        mode = None Text,
        content = None Text,
        src = Some "{{ stiltweb_jar_file }}",
        backup = Some True,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      register = Some "_jarfile"
    }
  , Task::{
      name = Some "Remove all but the five newest of jar file backups",
      `ansible.builtin.shell` = Some (Task.Poly_ansible_builtin_shell.Str ''
        ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --

      ''),
      args = Some {
        chdir = Some "{{ stiltweb_home }}",
        creates = None Text,
        executable = None Text,
        removes = None Text
    },
      register = Some "_r",
      changed_when = Some (Task.Poly_changed_when.Str "_r.stdout.startswith(\"removed\")")
    }
  , Task::{
      name = Some "Start/restart service",
      systemd = Some {
        name = Some "stiltweb.service",
        state = Some "{{ 'restarted' if _jarfile.changed or _config.changed else 'started' }}",
        daemon_reload = None Bool,
        enabled = Some "True",
        `daemon-reload` = Some "{{ 'yes' if _service.changed else 'no' }}",
        status = None Text
    }
    }
  , Task::{
      name = Some "Check that the service responds",
      uri = Some {
        url = "https://{{ stiltweb_domains | first }}/buildInfo",
        return_content = Some True,
        method = None Text,
        user = None Text,
        password = None Text
    },
      register = Some "r",
      failed_when = Some (Task.Poly_failed_when.Str "r.failed"),
      retries = Some 30,
      delay = Some 10,
      until = Some "not r.failed"
    }
]
