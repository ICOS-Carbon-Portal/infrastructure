-- Auto-generated from deploy.yml

let Task =
    { Type =
        { name : Text
    , template : Optional ({ src : Text, dest : Text })
    , register : Optional Text
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
      template = Some { src = "doi.service", dest = "/etc/systemd/system/doi.service" },
      register = Some "_service"
    }
  , Task::{
      name = "Create application.conf",
      template = Some { dest = "{{ doi_home }}/application.conf", src = "application.conf" },
      register = Some "_config"
    }
  , Task::{
      name = "Copy jarfile",
      register = Some "_jarfile",
      copy = Some { src = "{{ doi_jar_file }}", dest = "{{ doi_home }}/doi.jar", backup = True }
    }
  , Task::{
      name = "Remove all but the five newest of jar file backups",
      register = Some "_r",
      `ansible.builtin.shell` = Some ''
      ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --

    '',
      args = Some { chdir = "{{ doi_home }}" },
      changed_when = Some "_r.stdout.startswith(\"removed\")"
    }
  , Task::{
      name = "Start/restart service",
      systemd = Some {
        name = "doi.service"
      , enabled = True
      , `daemon-reload` = "{{ 'yes' if _service.changed else 'no' }}"
      , state = "{{ 'restarted' if _jarfile.changed or _config.changed else 'started' }}"
    }
    }
  , Task::{
      name = "Check that the service responds",
      register = Some "r",
      uri = Some { url = "https://{{ doi_domains | first }}/buildInfo", return_content = True },
      failed_when = Some "r.failed",
      retries = Some 30,
      delay = Some 10,
      until = Some "not r.failed"
    }
]
