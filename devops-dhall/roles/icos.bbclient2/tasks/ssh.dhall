-- Auto-generated from ../../../../devops/roles/icos.bbclient2/tasks/ssh.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create ssh directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ bbclient_ssh_dir }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = Some "448",
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Generate RSA keys",
      args = Some {
        chdir = None Text,
        creates = Some "{{ bbclient_ssh_key }}",
        executable = None Text,
        removes = None Text
    },
      command = Some ''
      ssh-keygen -q -t rsa -f {{ bbclient_ssh_key }} -N ""
        -C "bbclient_{{ bbclient_name }}@{{ inventory_hostname }}"
    ''
    }
  , Task::{
      name = Some "Create ssh config",
      copy = Some {
        dest = "{{ bbclient_ssh_config }}",
        mode = None Text,
        content = Some ''
        UserKnownHostsFile {{ bbclient_ssh_hosts }}
        Identityfile {{ bbclient_ssh_key }}

        {% for bbclient_remote in bbclient_remotes %}
        Host {{ bbclient_remote }}
            HostName {{ hostvars[bbclient_remote].bbserver_host }}
            User {{ hostvars[bbclient_remote].bbserver_user }}
            Port {{ hostvars[bbclient_remote].bbserver_port }}

        {% endfor %}

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Add ssh wrapper",
      copy = Some {
        dest = "{{ bbclient_ssh_bin }}",
        mode = Some "+x",
        content = Some ''
        #!/usr/bin/bash
        exec ssh -F {{ bbclient_ssh_config }} "$@"

      '',
        src = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
]
