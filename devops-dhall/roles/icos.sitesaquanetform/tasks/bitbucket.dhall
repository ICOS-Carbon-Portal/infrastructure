-- Auto-generated from ../../../../devops/roles/icos.sitesaquanetform/tasks/bitbucket.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create ssh directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ project_dir }}/.ssh",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Copy SSH public key",
      copy = Some {
        dest = "{{ project_dir }}/.ssh/",
        mode = Some "420",
        content = None Text,
        src = Some "id_rsa.pub",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Copy SSH private key",
      copy = Some {
        dest = "{{ project_dir }}/.ssh/",
        mode = Some "384",
        content = None Text,
        src = Some "id_rsa",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Check if known_hosts contains bitbucket",
      command = Some "ssh-keygen -F bitbucket.org",
      register = Some "bitbucket_known_hosts",
      failed_when = Some (Task.Poly_failed_when.Bool False),
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
  , Task::{
      name = Some "Update bitbucket known hosts",
      known_hosts = Some {
        name = "bitbucket.org",
        key = "{{ lookup('pipe', 'ssh-keyscan bitbucket.org, `dig +short bitbucket.org`') }}"
    },
      when = Some [ "bitbucket_known_hosts.stdout == \"\"" ]
    }
]
