-- Auto-generated from restore.yml

let Item =
    { Type =
        { name : Optional Text
    , command : Optional Text
    , args : Optional ({ chdir : Text, creates : Optional Text })
    , register : Optional Text
    , changed_when : Optional Bool
    , debug : Optional ({ msg : Text })
    , when : Optional (List Text)
    , `ansible.builtin.shell` : Optional Text
  }
    , default =
        { name = None Text
    , command = None Text
    , args = None ({ chdir : Text, creates : Optional Text })
    , register = None Text
    , changed_when = None Bool
    , debug = None ({ msg : Text })
    , when = None (List Text)
    , `ansible.builtin.shell` = None Text
  }
    }

in  [
    Item::{
      name = Some "List tables in the rdflog database",
      command = Some "./psql.sh -c '\\d' rdflog",
      args = Some { chdir = "{{ rdflog_home }}", creates = Some "/some/file" },
      register = Some "_r",
      changed_when = Some False
    }
  , Item::{
      debug = Some {
        msg = ''
        The 'rdflog' database is not empty, not restoring.

      ''
    },
      when = Some [ "_r.stderr != 'Did not find any relations.'", "_r.stdout != ''" ]
    }
  , Item::{
      name = Some "Restore database from file",
      args = Some { chdir = "{{ rdflog_home }}", creates = None Text },
      register = Some "_r",
      when = Some [ "_r.stderr == 'Did not find any relations.'", "_r.stdout == ''" ],
      `ansible.builtin.shell` = Some ''
      zcat {{ rdflog_restore_file }} | ./psql.sh

    ''
    }
]
