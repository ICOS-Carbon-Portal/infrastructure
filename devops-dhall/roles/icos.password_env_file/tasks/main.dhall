-- Auto-generated from ../../../../devops/roles/icos.password_env_file/tasks/main.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create password file",
      copy = Some {
        dest = "{{ file }}",
        mode = None Text,
        content = Some "{{ file_var }}={{ lookup('vars', set_fact) }}",
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      when = Some [ "lookup('vars', set_fact, default=False)" ]
    }
  , Task::{
      name = Some "Generate password file",
      shell = Some "umask 0077; openssl rand -hex {{ length }} | awk '{ print \"{{ file_var }}=\" $1 }' > {{ file }}",
      args = Some {
        chdir = None Text,
        creates = Some "{{ file }}",
        executable = None Text,
        removes = None Text
    }
    }
  , Task::{
      name = Some "Read password file",
      slurp = Some { src = "{{ file }}" },
      register = Some "_slurp"
    }
  , Task::{
      name = Some "Extract password",
      set_fact = Some (Task.Poly_set_fact.Str "{{ set_fact }}=\"{{ _slurp.content | b64decode | regex_replace('[^=]+=(\\\\S+)\\s*', '\\\\1') }}\"")
    }
]
