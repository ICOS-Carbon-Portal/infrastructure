-- Auto-generated from setup.yml

let Entry =
    { Type =
        { name : Text
    , user : Optional ({ name : Text, home : Text, create_home : Bool, shell : Text })
    , file : Optional ({ path : Text, mode : Optional Natural, state : Optional Text, owner : Optional Text, group : Optional Text })
    , include_role : Optional ({ name : Text, apply : { tags : Text } })
    , vars : Optional ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_envs : List Text, timer_content : Text })
    , tags : Optional Text
  }
    , default =
        { user = None ({ name : Text, home : Text, create_home : Bool, shell : Text })
    , file = None ({ path : Text, mode : Optional Natural, state : Optional Text, owner : Optional Text, group : Optional Text })
    , include_role = None ({ name : Text, apply : { tags : Text } })
    , vars = None ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_envs : List Text, timer_content : Text })
    , tags = None Text
  }
    }

in  [
    Entry::{
      name = "Create bbserver user",
      user = Some {
        name = "{{ bbserver_user }}"
      , home = "{{ bbserver_home | default(omit) }}"
      , create_home = True
      , shell = "/usr/bin/bash"
    }
    }
  , Entry::{
      name = "Change access rights on bbserver_home",
      file = Some {
        path = "{{ bbserver_home }}"
      , mode = Some 448
      , state = None Text
      , owner = None Text
      , group = None Text
    }
    }
  , Entry::{
      name = "Create repo directory",
      file = Some {
        path = "{{ bbserver_repo_home }}"
      , mode = None Natural
      , state = Some "directory"
      , owner = Some "{{ bbserver_user }}"
      , group = Some "{{ bbserver_user }}"
    }
    }
  , Entry::{
      name = "Install borg-compact timer",
      include_role = Some { name = "icos.timer", apply = { tags = "bbserver_compact" } },
      vars = Some {
        timer_user = "{{ bbserver_user }}"
      , timer_home = "{{ bbserver_home }}/bbserver-compact"
      , timer_name = "bbserver-compact"
      , timer_conf = ''
        OnCalendar=weekly
        RandomizedDelaySec=3h

      ''
      , timer_envs = [
          "BORG_RELOCATED_REPO_ACCESS_IS_OK=yes"
        , "BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes"
      ]
      , timer_content = ''
        #!/bin/bash
        # Since borg 1.2, it's not enough to prune repos, they have to be
        # compacted as well.
        set -eux

        cd $HOME/repos
        for repo in *.repo; do
          time borg compact --verbose $repo
        done

      ''
    },
      tags = Some "bbserver_compact"
    }
]
