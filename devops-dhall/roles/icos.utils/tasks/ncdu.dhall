-- Auto-generated from ../../../../devops/roles/icos.utils/tasks/ncdu.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install ncdu",
      tags = Some [ "ncdu" ],
      unarchive = Some {
        src = "{{ ncdu_url }}",
        dest = "/usr/local/bin/",
        remote_src = True,
        owner = None Text,
        group = None Text,
        include = None ((List Text)),
        list_files = None Bool,
        extra_opts = None ((List Text)),
        mode = None Text,
        creates = None Text
    },
      register = Some "_ncdu",
      diff = Some False
    }
  , Task::{
      name = Some "Check that ncdu is executable",
      command = Some "{{ _ncdu.dest }}/ncdu --version",
      changed_when = Some (Task.Poly_changed_when.Bool False),
      register = Some "_version"
    }
  , Task::{
      name = Some "Which version of ncdu was installed",
      debug = Some (Task.Poly_debug.Record { msg = "Installed {{ _version.stdout }}" })
    }
]
