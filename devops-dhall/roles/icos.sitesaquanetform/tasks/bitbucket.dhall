-- Auto-generated from bitbucket.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create ssh directory",
      file = Some {
        path = Some "{{ project_dir }}/.ssh"
      , state = Some "directory"
      , mode = None Text
      , owner = None Text
      , group = None Text
      , name = None Text
      , dest = None Text
      , recurse = None Bool
      , src = None Text
    }
    }
  , Task::{
      name = Some "Copy SSH public key",
      copy = Some {
        src = Some "id_rsa.pub"
      , dest = "{{ project_dir }}/.ssh/"
      , mode = Some "420"
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Copy SSH private key",
      copy = Some {
        src = Some "id_rsa"
      , dest = "{{ project_dir }}/.ssh/"
      , mode = Some "384"
      , content = None Text
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      name = Some "Check if known_hosts contains bitbucket",
      command = Some "ssh-keygen -F bitbucket.org",
      register = Some "bitbucket_known_hosts",
      failed_when = Some "False",
      changed_when = Some "False"
    }
  , Task::{
      name = Some "Update bitbucket known hosts",
      known_hosts = Some {
        name = "bitbucket.org"
      , key = "{{ lookup('pipe', 'ssh-keyscan bitbucket.org, `dig +short bitbucket.org`') }}"
    },
      when = Some [ "bitbucket_known_hosts.stdout == \"\"" ]
    }
]
