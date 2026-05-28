-- Auto-generated from deploy.yml

let Item =
    { Type =
        { name : Optional Text
    , template : Optional ({ src : Text, dest : Text })
    , register : Optional Text
    , copy : Optional ({ src : Text, dest : Text, backup : Bool })
    , `ansible.builtin.shell` : Optional Text
    , args : Optional ({ chdir : Text })
    , changed_when : Optional Text
    , import_tasks : Optional Text
    , tags : Optional Text
    , uri : Optional ({ url : Text, return_content : Bool })
    , failed_when : Optional Text
    , retries : Optional Natural
    , delay : Optional Natural
    , until : Optional Text
  }
    , default =
        { name = None Text
    , template = None ({ src : Text, dest : Text })
    , register = None Text
    , copy = None ({ src : Text, dest : Text, backup : Bool })
    , `ansible.builtin.shell` = None Text
    , args = None ({ chdir : Text })
    , changed_when = None Text
    , import_tasks = None Text
    , tags = None Text
    , uri = None ({ url : Text, return_content : Bool })
    , failed_when = None Text
    , retries = None Natural
    , delay = None Natural
    , until = None Text
  }
    }

in  [
    Item::{
      name = Some "Add systemd service",
      template = Some { src = "cpdata.service", dest = "/etc/systemd/system/cpdata.service" },
      register = Some "_service"
    }
  , Item::{
      name = Some "Copy jarfile",
      register = Some "_jarfile",
      copy = Some {
        src = "{{ cpdata_jar_file }}"
      , dest = "{{ cpdata_home }}/cpdata.jar"
      , backup = True
    }
    }
  , Item::{
      name = Some "Remove all but the five newest of jar file backups",
      register = Some "_r",
      `ansible.builtin.shell` = Some ''
      ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --

    '',
      args = Some { chdir = "{{ cpdata_home }}" },
      changed_when = Some "_r.stdout.startswith(\"removed\")"
    }
  , Item::{ import_tasks = Some "config.yml", tags = Some "cpdata_config" }
  , Item::{
      name = Some "Check that the service responds",
      register = Some "r",
      uri = Some { url = "https://{{ cpdata_domains | first }}/buildInfo", return_content = True },
      failed_when = Some "r.failed",
      retries = Some 30,
      delay = Some 10,
      until = Some "not r.failed"
    }
]
