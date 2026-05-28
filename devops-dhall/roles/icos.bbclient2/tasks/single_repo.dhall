-- Auto-generated from single_repo.yml

let Entry =
    { Type =
        { name : Text
    , check_mode : Optional Bool
    , slurpfact : Optional ({ path : Text, fact : Text })
    , delegate_to : Optional Text
    , block : Optional (List ({ name : Text, check_mode : Optional Bool, shellfact : Optional ({ exec : Text, fact : Text }), authorized_key : Optional ({ user : Text, state : Text, key : Text, key_options : Text }), blockinfile : Optional ({ create : Bool, path : Text, marker : Text, block : Text }), command : Optional Text, register : Optional Text, changed_when : Optional (List Text), failed_when : Optional (List Text) }))
    , become : Optional Bool
    , become_user : Optional Text
  }
    , default =
        { check_mode = None Bool
    , slurpfact = None ({ path : Text, fact : Text })
    , delegate_to = None Text
    , block = None (List ({ name : Text, check_mode : Optional Bool, shellfact : Optional ({ exec : Text, fact : Text }), authorized_key : Optional ({ user : Text, state : Text, key : Text, key_options : Text }), blockinfile : Optional ({ create : Bool, path : Text, marker : Text, block : Text }), command : Optional Text, register : Optional Text, changed_when : Optional (List Text), failed_when : Optional (List Text) }))
    , become = None Bool
    , become_user = None Text
  }
    }

in  [
    Entry::{
      name = "Read the public key",
      check_mode = Some False,
      slurpfact = Some { path = "{{ bbclient_ssh_key }}.pub", fact = "bbclient_key_data" }
    }
  , Entry::{
      name = "Configure remote - bbserver - host",
      delegate_to = Some "{{ bbclient_remote }}",
      block = Some [
        {
          name = "Retrieve host keys",
          check_mode = Some False,
          shellfact = Some {
            exec = "ssh-keyscan -p {{ hostvars[bbclient_remote].bbserver_port }} localhost | sed \"s/localhost/{{ hostvars[bbclient_remote].bbserver_host }}/\" | sort -u"
          , fact = "bbclient_remote_keys"
        },
          authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text }),
          blockinfile = None ({ create : Bool, path : Text, marker : Text, block : Text }),
          command = None Text,
          register = None Text,
          changed_when = None (List Text),
          failed_when = None (List Text)
        }
      , {
          name = "Install public key",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          authorized_key = Some {
            user = "{{ bbclient_remote_user }}"
          , state = "present"
          , key = "{{ bbclient_key_data }}"
          , key_options = "command=\"/usr/local/bin/borg serve --restrict-to-path {{ bbclient_remote_repo }}\",restrict"
        },
          blockinfile = None ({ create : Bool, path : Text, marker : Text, block : Text }),
          command = None Text,
          register = None Text,
          changed_when = None (List Text),
          failed_when = None (List Text)
        }
    ]
    }
  , Entry::{
      name = "Configure local - bbclient - host",
      block = Some [
        {
          name = "Update known_hosts",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text }),
          blockinfile = Some {
            create = True
          , path = "{{ bbclient_ssh_hosts }}"
          , marker = "# {mark} {{ bbclient_remote }}"
          , block = ''
            {{ bbclient_remote_keys }}

          ''
        },
          command = None Text,
          register = None Text,
          changed_when = None (List Text),
          failed_when = None (List Text)
        }
      , {
          name = "Initialize repo",
          check_mode = None Bool,
          shellfact = None ({ exec : Text, fact : Text }),
          authorized_key = None ({ user : Text, state : Text, key : Text, key_options : Text }),
          blockinfile = None ({ create : Bool, path : Text, marker : Text, block : Text }),
          command = Some ''
          {{ bbclient_wrapper }} init {{ bbclient_repo_url }} --encryption=none

        '',
          register = Some "r",
          changed_when = Some [ "r.rc == 0" ],
          failed_when = Some [ "r.rc != 0", "not r.stderr.startswith('A repository already exists at')" ]
        }
    ],
      become = Some True,
      become_user = Some "{{ bbclient_user }}"
    }
]
