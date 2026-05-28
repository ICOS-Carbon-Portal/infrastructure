-- Auto-generated from main.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : Text })
    , lineinfile : Optional ({ path : Text, regexp : Text, line : Text, state : Text, create : Bool })
    , loop : Optional (List Text)
    , notify : Optional Text
    , copy : Optional ({ src : Text, dest : Text, validate : Text })
    , find : Optional ({ paths : Text, patterns : Text, excludes : Text })
    , register : Optional Text
    , file : Optional ({ name : Text, state : Text })
    , systemd : Optional ({ name : Text, enabled : Bool, state : Text })
    , uri : Optional ({ url : Text })
    , retries : Optional Natural
  }
    , default =
        { apt = None ({ name : Text })
    , lineinfile = None ({ path : Text, regexp : Text, line : Text, state : Text, create : Bool })
    , loop = None (List Text)
    , notify = None Text
    , copy = None ({ src : Text, dest : Text, validate : Text })
    , find = None ({ paths : Text, patterns : Text, excludes : Text })
    , register = None Text
    , file = None ({ name : Text, state : Text })
    , systemd = None ({ name : Text, enabled : Bool, state : Text })
    , uri = None ({ url : Text })
    , retries = None Natural
  }
    }

in  [
    Task::{ name = "Install mtail", apt = Some { name = "mtail" } }
  , Task::{
      name = "Configure mtail",
      lineinfile = Some {
        path = "/etc/default/mtail"
      , regexp = "^#?{{ item.key }}="
      , line = "{{ item.key }}={{ item.val }}"
      , state = "present"
      , create = False
    },
      loop = Some [
        { key = "LOGS", val = "{{ mtail_logs | join(',') }}" }
      , { key = "PORT", val = "{{ mtail_port }}" }
      , { key = "HOST", val = "{{ mtail_host }}" }
    ],
      notify = Some "reload mtail"
    }
  , Task::{
      name = "Install configure icos programs",
      loop = Some [ "{{ mtail_programs }}" ],
      notify = Some "reload mtail",
      copy = Some {
        src = "{{ item }}"
      , dest = "/etc/mtail"
      , validate = "mtail --compile_only -port 0 --progs %s"
    }
    }
  , Task::{
      name = "Find unconfigured icos programs",
      find = Some {
        paths = "/etc/mtail"
      , patterns = "icos-*.mtail"
      , excludes = "{{ mtail_programs }}"
    },
      register = Some "_find"
    }
  , Task::{
      name = "Remove unconfigured icos programs",
      loop = Some [ "{{ _find.files | map(attribute='path') }}" ],
      notify = Some "reload mtail",
      file = Some { name = "{{ item }}", state = "absent" }
    }
  , Task::{
      name = "Start mtail service",
      systemd = Some { name = "mtail", enabled = True, state = "started" }
    }
  , Task::{
      name = "Check that the mtail http server is responding",
      uri = Some { url = "http://{{ mtail_host }}:{{ mtail_port }}" },
      retries = Some 10
    }
]
