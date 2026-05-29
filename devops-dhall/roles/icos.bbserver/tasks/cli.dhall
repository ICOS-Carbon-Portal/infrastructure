-- Auto-generated from ../../../../devops/roles/icos.bbserver/tasks/cli.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create {{ bbserver_home }}/bin directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ bbserver_home }}/bin",
          state = Some "directory",
          owner = Some "{{ bbserver_user }}",
          group = Some "{{ bbserver_user }}",
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Copy bbserver.py",
      template = Some {
        src = "bbserver.py",
        dest = "{{ bbserver_home }}/bin/bbserver",
        mode = Some "+x",
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    }
    }
  , Task::{
      name = Some "Prime borg cache by running 'bbserver list' each night",
      cron = Some {
        user = Some "bbserver",
        job = Some "{{ bbserver_home }}/bin/bbserver list > /dev/null 2>&1",
        hour = Some "{{ 4 | random(seed='bbserver') }}",
        minute = Some "{{ 60 | random(seed='bbserver') }}",
        name = "bbserver_prime_borg_cache",
        state = None Text,
        special_time = None Text
    }
    }
]
