-- Auto-generated from bitbucket.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text })
    , copy : Optional ({ src : Text, dest : Text, mode : Natural })
    , command : Optional Text
    , register : Optional Text
    , failed_when : Optional Bool
    , changed_when : Optional Bool
    , known_hosts : Optional ({ name : Text, key : Text })
    , when : Optional Text
  }
    , default =
        { file = None ({ path : Text, state : Text })
    , copy = None ({ src : Text, dest : Text, mode : Natural })
    , command = None Text
    , register = None Text
    , failed_when = None Bool
    , changed_when = None Bool
    , known_hosts = None ({ name : Text, key : Text })
    , when = None Text
  }
    }

in  [
    Task::{
      name = "Create ssh directory",
      file = Some { path = "{{ project_dir }}/.ssh", state = "directory" }
    }
  , Task::{
      name = "Copy SSH public key",
      copy = Some { src = "id_rsa.pub", dest = "{{ project_dir }}/.ssh/", mode = 420 }
    }
  , Task::{
      name = "Copy SSH private key",
      copy = Some { src = "id_rsa", dest = "{{ project_dir }}/.ssh/", mode = 384 }
    }
  , Task::{
      name = "Check if known_hosts contains bitbucket",
      command = Some "ssh-keygen -F bitbucket.org",
      register = Some "bitbucket_known_hosts",
      failed_when = Some False,
      changed_when = Some False
    }
  , Task::{
      name = "Update bitbucket known hosts",
      known_hosts = Some {
        name = "bitbucket.org"
      , key = "{{ lookup('pipe', 'ssh-keyscan bitbucket.org, `dig +short bitbucket.org`') }}"
    },
      when = Some "bitbucket_known_hosts.stdout == \"\""
    }
]
