-- Auto-generated from repos.yml

let Item =
    { Type =
        { name : Optional Text
    , copy : Optional ({ dest : Text, content : Text })
    , include_tasks : Optional Text
    , loop : Optional Text
    , loop_control : Optional ({ loop_var : Text })
    , command : Optional Text
    , environment : Optional ({ BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK : Text, BORG_RELOCATED_REPO_ACCESS_IS_OK : Text })
    , changed_when : Optional Bool
  }
    , default =
        { name = None Text
    , copy = None ({ dest : Text, content : Text })
    , include_tasks = None Text
    , loop = None Text
    , loop_control = None ({ loop_var : Text })
    , command = None Text
    , environment = None ({ BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK : Text, BORG_RELOCATED_REPO_ACCESS_IS_OK : Text })
    , changed_when = None Bool
  }
    }

in  [
    Item::{
      name = Some "Create new repo file",
      copy = Some {
        dest = "{{ bbclient_repo_file }}"
      , content = ''
        # Be aware that the "hostnames" in this file are then transformed by the
        # ssh config at {{ bbclient_ssh_config }}
        {% for br in bbclient_remotes %}
        {{ br }}:repos/{{ bbclient_name }}.repo
        {% endfor %}

      ''
    }
    }
  , Item::{
      include_tasks = Some "single_repo.yml",
      loop = Some "{{ bbclient_remotes }}",
      loop_control = Some { loop_var = "bbclient_remote" }
    }
  , Item::{
      name = Some "Run bbclient-all info to verify access",
      command = Some "{{ bbclient_all }} info",
      environment = Some {
        BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "y"
      , BORG_RELOCATED_REPO_ACCESS_IS_OK = "y"
    },
      changed_when = Some False
    }
]
