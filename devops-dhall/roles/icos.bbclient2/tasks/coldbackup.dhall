-- Auto-generated from coldbackup.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : Text })
    , template : Optional ({ src : Text, dest : Text, mode : Text })
    , loop : Optional (List Text)
    , include_role : Optional ({ name : Text })
    , vars : Optional ({ timer_home : Text, timer_exec : Text, timer_name : Text, timer_conf : Text, timer_envs : List Text })
  }
    , default =
        { apt = None ({ name : Text })
    , template = None ({ src : Text, dest : Text, mode : Text })
    , loop = None (List Text)
    , include_role = None ({ name : Text })
    , vars = None ({ timer_home : Text, timer_exec : Text, timer_name : Text, timer_conf : Text, timer_envs : List Text })
  }
    }

in  [
    Task::{ name = "Install python3-click", apt = Some { name = "python3-click" } }
  , Task::{
      name = "Create coldbackup helper scripts",
      template = Some { src = "{{ item }}", dest = "{{ bbclient_bin_dir }}", mode = "+x" },
      loop = Some [ "bbclient-coldbackup", "bbclient-coldrestore" ]
    }
  , Task::{
      name = "Add coldbackup systemd timer",
      include_role = Some { name = "icos.timer" },
      vars = Some {
        timer_home = "{{ bbclient_home }}"
      , timer_exec = "{{ bbclient_bin_dir }}/bbclient-coldbackup"
      , timer_name = "bbclient-{{ bbclient_name }}-coldbackup"
      , timer_conf = ''
        OnCalendar={{ bbclient_coldbackup_hour }}:{{ bbclient_coldbackup_minute }}

      ''
      , timer_envs = [ "PYTHONUNBUFFERED=1" ]
    }
    }
]
