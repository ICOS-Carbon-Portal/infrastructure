-- Auto-generated from restore.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "List tables in the rdflog database",
      command = Some "./psql.sh -c '\\d' rdflog",
      args = Some {
        creates = Some "/some/file"
      , chdir = Some "{{ rdflog_home }}"
      , executable = None Text
      , removes = None Text
    },
      register = Some "_r",
      changed_when = Some "False"
    }
  , Task::{
      debug = Some {
        msg = ''
        The 'rdflog' database is not empty, not restoring.

      ''
    },
      when = Some [ "_r.stderr != 'Did not find any relations.'", "_r.stdout != ''" ]
    }
  , Task::{
      name = Some "Restore database from file",
      `ansible.builtin.shell` = Some ''
      zcat {{ rdflog_restore_file }} | ./psql.sh

    '',
      args = Some {
        creates = None Text
      , chdir = Some "{{ rdflog_home }}"
      , executable = None Text
      , removes = None Text
    },
      register = Some "_r",
      when = Some [ "_r.stderr == 'Did not find any relations.'", "_r.stdout == ''" ]
    }
]
