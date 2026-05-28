-- Auto-generated from docker.yml

let Entry =
    { Type =
        { name : Text
    , pip : Optional ({ name : Text, state : Text })
    , include_role : Optional ({ name : Text })
    , vars : Optional ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_envs : List Text, timer_content : Text, timer_exec : Text })
  }
    , default =
        { pip = None ({ name : Text, state : Text })
    , include_role = None ({ name : Text })
    , vars = None ({ timer_user : Text, timer_home : Text, timer_name : Text, timer_conf : Text, timer_envs : List Text, timer_content : Text, timer_exec : Text })
  }
    }

in  [
    Entry::{ name = "pip install docker", pip = Some { name = "docker", state = "present" } }
  , Entry::{
      name = "Create dockermon timer",
      include_role = Some { name = "icos.timer" },
      vars = Some {
        timer_user = None Text
      , timer_home = "{{ dockermon_home }}"
      , timer_name = "node-exporter-dockermon"
      , timer_conf = "OnCalendar=*:0/5"
      , timer_envs = [ "PYTHONUNBUFFERED=1", "PATH=/usr/bin:/usr/local/bin" ]
      , timer_content = "{{ lookup('template', 'dockermon.py') }}"
      , timer_exec = "/bin/bash -c 'set -o pipefail && {{ timer_dest }} | uniq | sponge {{ dockermon_prom }}'"
    }
    }
]
