-- Auto-generated from ncdu.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install ncdu",
      tags = Some [ "ncdu" ],
      unarchive = Some {
        src = "{{ ncdu_url }}"
      , dest = "/usr/local/bin/"
      , remote_src = True
      , owner = None Text
      , group = None Text
      , include = None (List Text)
      , list_files = None Bool
      , extra_opts = None (List Text)
      , mode = None Text
      , creates = None Text
    },
      register = Some "_ncdu",
      diff = Some False
    }
  , Task::{
      name = Some "Check that ncdu is executable",
      command = Some "{{ _ncdu.dest }}/ncdu --version",
      changed_when = Some "False",
      register = Some "_version"
    }
  , Task::{
      name = Some "Which version of ncdu was installed",
      debug = Some { msg = "Installed {{ _version.stdout }}" }
    }
]
