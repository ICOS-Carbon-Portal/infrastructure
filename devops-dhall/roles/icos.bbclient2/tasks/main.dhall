-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , tags : Optional Text
    , import_tasks : Optional Text
    , become : Optional Bool
    , become_user : Optional Text
    , copy : Optional ({ dest : Text, content : Text })
    , when : Optional (List Text)
    , include_role : Optional Text
    , vars : Optional ({ timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text })
  }
    , default =
        { name = None Text
    , tags = None Text
    , import_tasks = None Text
    , become = None Bool
    , become_user = None Text
    , copy = None ({ dest : Text, content : Text })
    , when = None (List Text)
    , include_role = None Text
    , vars = None ({ timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text })
  }
    }

in  [
    Item::{
      name = Some "Setup local ssh directory",
      tags = Some "bbclient_ssh",
      import_tasks = Some "ssh.yml",
      become = Some True,
      become_user = Some "{{ bbclient_user }}"
    }
  , Item::{
      name = Some "Install bbclient shell-scripts",
      tags = Some "bbclient_scripts",
      import_tasks = Some "scripts.yml",
      become = Some True,
      become_user = Some "{{ bbclient_user }}"
    }
  , Item::{ tags = Some "bbclient_repos", import_tasks = Some "repos.yml" }
  , Item::{
      name = Some "Create patterns.lst",
      copy = Some { dest = "{{ bbclient_patterns_path }}", content = "{{ bbclient_patterns }}" }
    }
  , Item::{
      tags = Some "bbclient_coldbackup",
      import_tasks = Some "coldbackup.yml",
      become = Some True,
      become_user = Some "{{ bbclient_user }}",
      when = Some [ "bbclient_coldbackup is defined" ]
    }
  , Item::{
      name = Some "Install bbclient backup script",
      tags = Some "bbclient_timer",
      when = Some [ "bbclient_timer_content is defined" ],
      include_role = Some "name=icos.timer",
      vars = Some {
        timer_home = "{{ bbclient_home }}/timer"
      , timer_name = "bbclient-{{ bbclient_name }}"
      , timer_conf = "{{ bbclient_timer_conf }}"
      , timer_content = "{{ bbclient_timer_content }}"
    }
    }
  , Item::{ tags = Some "bbclient_just", import_tasks = Some "just.yml" }
]
