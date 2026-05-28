-- Auto-generated from ssh.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text, mode : Natural })
    , args : Optional ({ creates : Text })
    , command : Optional Text
    , copy : Optional ({ dest : Text, content : Text, mode : Optional Text })
  }
    , default =
        { file = None ({ path : Text, state : Text, mode : Natural })
    , args = None ({ creates : Text })
    , command = None Text
    , copy = None ({ dest : Text, content : Text, mode : Optional Text })
  }
    }

in  [
    Task::{
      name = "Create ssh directory",
      file = Some { path = "{{ bbclient_ssh_dir }}", state = "directory", mode = 448 }
    }
  , Task::{
      name = "Generate RSA keys",
      args = Some { creates = "{{ bbclient_ssh_key }}" },
      command = Some ''
      ssh-keygen -q -t rsa -f {{ bbclient_ssh_key }} -N ""
        -C "bbclient_{{ bbclient_name }}@{{ inventory_hostname }}"
    ''
    }
  , Task::{
      name = "Create ssh config",
      copy = Some {
        dest = "{{ bbclient_ssh_config }}"
      , content = ''
        UserKnownHostsFile {{ bbclient_ssh_hosts }}
        Identityfile {{ bbclient_ssh_key }}

        {% for bbclient_remote in bbclient_remotes %}
        Host {{ bbclient_remote }}
            HostName {{ hostvars[bbclient_remote].bbserver_host }}
            User {{ hostvars[bbclient_remote].bbserver_user }}
            Port {{ hostvars[bbclient_remote].bbserver_port }}

        {% endfor %}

      ''
      , mode = None Text
    }
    }
  , Task::{
      name = "Add ssh wrapper",
      copy = Some {
        dest = "{{ bbclient_ssh_bin }}"
      , content = ''
        #!/usr/bin/bash
        exec ssh -F {{ bbclient_ssh_config }} "$@"

      ''
      , mode = Some "+x"
    }
    }
]
