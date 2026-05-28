-- Auto-generated from deploy.yml

let Item =
    { Type =
        { name : Optional Text
    , template : Optional ({ src : Text, dest : Text })
    , when : Optional (List Text)
    , block : Optional (List ({ name : Text, delegate_to : Optional Text, run_once : Optional Bool, fetch : Optional ({ src : Text, dest : Text, flat : Bool }), set_fact : Optional ({ stiltcluster_jar_file : Text, cacheable : Bool }) }))
    , copy : Optional ({ src : Text, dest : Text, backup : Bool })
    , notify : Optional Text
    , `ansible.builtin.shell` : Optional Text
    , args : Optional ({ chdir : Text })
    , register : Optional Text
    , changed_when : Optional Text
    , systemd : Optional ({ name : Text, enabled : Bool, `daemon-reload` : Bool, state : Text })
  }
    , default =
        { name = None Text
    , template = None ({ src : Text, dest : Text })
    , when = None (List Text)
    , block = None (List ({ name : Text, delegate_to : Optional Text, run_once : Optional Bool, fetch : Optional ({ src : Text, dest : Text, flat : Bool }), set_fact : Optional ({ stiltcluster_jar_file : Text, cacheable : Bool }) }))
    , copy = None ({ src : Text, dest : Text, backup : Bool })
    , notify = None Text
    , `ansible.builtin.shell` = None Text
    , args = None ({ chdir : Text })
    , register = None Text
    , changed_when = None Text
    , systemd = None ({ name : Text, enabled : Bool, `daemon-reload` : Bool, state : Text })
  }
    }

in  [
    Item::{
      name = Some "Add systemd service",
      template = Some {
        src = "stiltcluster.service"
      , dest = "/etc/systemd/system/stiltcluster.service"
    }
    }
  , Item::{
      when = Some [
        "inventory_hostname != stiltcluster_fetch_host"
      , "stiltcluster_jar_file is undefined"
    ],
      block = Some [
        {
          name = "Retrive stiltcluster.jar",
          delegate_to = Some "{{ stiltcluster_fetch_host }}",
          run_once = Some True,
          fetch = Some {
            src = "{{ stiltcluster_fetch_path }}"
          , dest = "tmp/stiltcluster.jar"
          , flat = True
        },
          set_fact = None ({ stiltcluster_jar_file : Text, cacheable : Bool })
        }
      , {
          name = "Temporarily set stiltcluster_jar_file",
          delegate_to = None Text,
          run_once = None Bool,
          fetch = None ({ src : Text, dest : Text, flat : Bool }),
          set_fact = Some { stiltcluster_jar_file = "tmp/stiltcluster.jar", cacheable = False }
        }
    ]
    }
  , Item::{
      name = Some "Copy jarfile",
      when = Some [ "stiltcluster_jar_file is defined" ],
      copy = Some {
        src = "{{ stiltcluster_jar_file }}"
      , dest = "{{ stiltcluster_home }}/stiltcluster.jar"
      , backup = True
    },
      notify = Some "restart stiltcluster"
    }
  , Item::{
      name = Some "Remove all but the five newest of jar file backups",
      `ansible.builtin.shell` = Some ''
      ls -1tr *.jar*~ 2>/dev/null | tail +6 | xargs rm -fv --

    '',
      args = Some { chdir = "{{ stiltcluster_home }}" },
      register = Some "_r",
      changed_when = Some "_r.stdout.startswith(\"removed\")"
    }
  , Item::{
      name = Some "Make sure stiltcluster is started",
      systemd = Some {
        name = "stiltcluster.service"
      , enabled = True
      , `daemon-reload` = True
      , state = "started"
    }
    }
]
