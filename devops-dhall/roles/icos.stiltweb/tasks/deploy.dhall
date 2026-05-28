-- Auto-generated from deploy.yml

let Task =
    { Type =
        { name : Text
    , template : Optional ({ src : Text, dest : Text })
    , register : Optional Text
    , when : Optional Text
    , copy : Optional ({ src : Text, dest : Text, backup : Bool })
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
    , when = None Text
    , copy = None ({ src : Text, dest : Text, backup : Bool })
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
      template = Some { src = "stiltweb.service", dest = "/etc/systemd/system/stiltweb.service" },
      register = Some "_service"
    }
  , Task::{
      name = "Create configuration file",
      template = Some { dest = "{{ stiltweb_home }}/local.conf", src = "local.conf" },
      register = Some "_config"
    }
  , Task::{
      name = "Copy jarfile",
      register = Some "_jarfile",
      when = Some "stiltweb_jar_file is defined",
      copy = Some {
        src = "{{ stiltweb_jar_file }}"
      , dest = "{{ stiltweb_home }}/stiltweb.jar"
      , backup = True
    }
    }
  , Task::{
      name = "Remove all but the five newest of jar file backups",
      register = Some "_r",
      `ansible.builtin.shell` = Some ''
      ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --

    '',
      args = Some { chdir = "{{ stiltweb_home }}" },
      changed_when = Some "_r.stdout.startswith(\"removed\")"
    }
  , Task::{
      name = "Start/restart service",
      systemd = Some {
        name = "stiltweb.service"
      , enabled = True
      , `daemon-reload` = "{{ 'yes' if _service.changed else 'no' }}"
      , state = "{{ 'restarted' if _jarfile.changed or _config.changed else 'started' }}"
    }
    }
  , Task::{
      name = "Check that the service responds",
      register = Some "r",
      uri = Some {
        url = "https://{{ stiltweb_domains | first }}/buildInfo"
      , return_content = True
    },
      failed_when = Some "r.failed",
      retries = Some 30,
      delay = Some 10,
      until = Some "not r.failed"
    }
]
