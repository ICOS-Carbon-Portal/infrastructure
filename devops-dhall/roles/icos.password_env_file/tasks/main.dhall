-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , copy : Optional ({ dest : Text, content : Text })
    , when : Optional Text
    , shell : Optional Text
    , args : Optional ({ creates : Text })
    , slurp : Optional ({ src : Text })
    , register : Optional Text
    , set_fact : Optional Text
  }
    , default =
        { copy = None ({ dest : Text, content : Text })
    , when = None Text
    , shell = None Text
    , args = None ({ creates : Text })
    , slurp = None ({ src : Text })
    , register = None Text
    , set_fact = None Text
  }
    }

in  [
    Task::{
      name = "Create password file",
      copy = Some {
        dest = "{{ file }}"
      , content = "{{ file_var }}={{ lookup('vars', set_fact) }}"
    },
      when = Some "lookup('vars', set_fact, default=False)"
    }
  , Task::{
      name = "Generate password file",
      shell = Some "umask 0077; openssl rand -hex {{ length }} | awk '{ print \"{{ file_var }}=\" $1 }' > {{ file }}",
      args = Some { creates = "{{ file }}" }
    }
  , Task::{
      name = "Read password file",
      slurp = Some { src = "{{ file }}" },
      register = Some "_slurp"
    }
  , Task::{
      name = "Extract password",
      set_fact = Some "{{ set_fact }}=\"{{ _slurp.content | b64decode | regex_replace('[^=]+=(\\\\S+)\\s*', '\\\\1') }}\""
    }
]
