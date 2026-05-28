-- Auto-generated from dirsize.yml

let Task =
    { Type =
        { name : Text
    , file : Optional ({ path : Text, state : Text })
    , copy : Optional ({ dest : Text, force : Bool, content : Text })
    , lineinfile : Optional ({ path : Text, line : Text, state : Text })
    , loop : Optional Text
    , include_role : Optional ({ name : Text })
    , vars : Optional ({ timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text })
  }
    , default =
        { file = None ({ path : Text, state : Text })
    , copy = None ({ dest : Text, force : Bool, content : Text })
    , lineinfile = None ({ path : Text, line : Text, state : Text })
    , loop = None Text
    , include_role = None ({ name : Text })
    , vars = None ({ timer_home : Text, timer_name : Text, timer_conf : Text, timer_content : Text })
  }
    }

in  [
    Task::{
      name = "Create dirsize home directory",
      file = Some { path = "{{ dirsize_home }}", state = "directory" }
    }
  , Task::{
      name = "Make sure that the dirnames file exists.",
      copy = Some { dest = "{{ dirsize_dirnames }}", force = False, content = "" }
    }
  , Task::{
      name = "Ensure that initial directories are in dirnames.txt",
      lineinfile = Some { path = "{{ dirsize_dirnames }}", line = "{{ item }}", state = "present" },
      loop = Some "{{ dirsize_initial }}"
    }
  , Task::{
      name = "Create timer for node-exporter-dirsize",
      include_role = Some { name = "icos.timer" },
      vars = Some {
        timer_home = "{{ dirsize_home }}"
      , timer_name = "node-exporter-dirsize"
      , timer_conf = "OnCalendar=hourly"
      , timer_content = ''
        #!/bin/bash
        # Read directory name from a file that can be dynamically populated by
        # ansible.
        xargs -r -a {{ dirsize_dirnames }} {{ dirsize_sh }} | uniq | sponge {{ dirsize_prom }}

      ''
    }
    }
]
