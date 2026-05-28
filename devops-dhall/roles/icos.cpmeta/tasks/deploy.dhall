-- Auto-generated from deploy.yml

let Item =
    { Type =
        { name : Optional Text
    , copy : Optional ({ src : Text, dest : Text, backup : Bool })
    , register : Optional Text
    , `ansible.builtin.shell` : Optional Text
    , args : Optional ({ chdir : Text })
    , changed_when : Optional Text
    , include_tasks : Optional Text
    , vars : Optional ({ _restart_needed : Text })
  }
    , default =
        { name = None Text
    , copy = None ({ src : Text, dest : Text, backup : Bool })
    , register = None Text
    , `ansible.builtin.shell` = None Text
    , args = None ({ chdir : Text })
    , changed_when = None Text
    , include_tasks = None Text
    , vars = None ({ _restart_needed : Text })
  }
    }

in  [
    Item::{
      name = Some "Copy jarfile",
      copy = Some {
        src = "{{ cpmeta_jar_file }}"
      , dest = "{{ cpmeta_home }}/cpmeta.jar"
      , backup = True
    },
      register = Some "_jarfile"
    }
  , Item::{
      name = Some "Remove all but the five newest of jar file backups",
      register = Some "_r",
      `ansible.builtin.shell` = Some ''
      ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --

    '',
      args = Some { chdir = "{{ cpmeta_home }}" },
      changed_when = Some "_r.stdout.startswith(\"removed\")"
    }
  , Item::{
      include_tasks = Some "restart.yml",
      vars = Some { _restart_needed = "{{ _config.changed or _jarfile.changed }}" }
    }
]
