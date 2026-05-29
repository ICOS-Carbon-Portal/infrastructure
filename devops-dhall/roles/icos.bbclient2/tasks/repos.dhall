-- Auto-generated from repos.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create new repo file",
      copy = Some {
        src = None Text
      , dest = "{{ bbclient_repo_file }}"
      , mode = None Text
      , content = Some ''
        # Be aware that the "hostnames" in this file are then transformed by the
        # ssh config at {{ bbclient_ssh_config }}
        {% for br in bbclient_remotes %}
        {{ br }}:repos/{{ bbclient_name }}.repo
        {% endfor %}

      ''
      , backup = None Bool
      , owner = None Text
      , group = None Text
      , force = None Text
      , validate = None Text
    }
    }
  , Task::{
      include_tasks = Some "single_repo.yml",
      loop = Some [ "{{ bbclient_remotes }}" ],
      loop_control = Some { loop_var = Some "bbclient_remote", label = None Text }
    }
  , Task::{
      name = Some "Run bbclient-all info to verify access",
      command = Some "{{ bbclient_all }} info",
      environment = Some {
        BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = Some "y"
      , BORG_RELOCATED_REPO_ACCESS_IS_OK = Some "y"
      , PIPX_BIN_DIR = None Text
      , GOPATH = None Text
    },
      changed_when = Some "False"
    }
]
