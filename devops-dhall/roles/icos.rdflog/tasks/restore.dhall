-- Auto-generated from ../../../../devops/roles/icos.rdflog/tasks/restore.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "List tables in the rdflog database",
      command = Some "./psql.sh -c '\\d' rdflog",
      args = Some {
        chdir = Some "{{ rdflog_home }}",
        creates = Some "/some/file",
        executable = None Text,
        removes = None Text
    },
      register = Some "_r",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
  , Task::{
      debug = Some (Task.Poly_debug.Record {
          msg = ''
          The 'rdflog' database is not empty, not restoring.

        ''
      }),
      when = Some [ "_r.stderr != 'Did not find any relations.'", "_r.stdout != ''" ]
    }
  , Task::{
      name = Some "Restore database from file",
      `ansible.builtin.shell` = Some (Task.Poly_ansible_builtin_shell.Str ''
        zcat {{ rdflog_restore_file }} | ./psql.sh

      ''),
      args = Some {
        chdir = Some "{{ rdflog_home }}",
        creates = None Text,
        executable = None Text,
        removes = None Text
    },
      register = Some "_r",
      when = Some [ "_r.stderr == 'Did not find any relations.'", "_r.stdout == ''" ]
    }
]
