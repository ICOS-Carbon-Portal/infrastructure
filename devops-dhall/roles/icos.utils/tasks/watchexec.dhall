-- Auto-generated from watchexec.yml

let Item =
    { Type =
        { name : Optional Text
    , file : Optional ({ name : Text, state : Text })
    , when : Optional Text
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ watchexec_version : Text, cacheable : Bool }) }))
    , apt : Optional ({ deb : Text })
    , shell : Optional Text
    , changed_when : Optional Bool
    , register : Optional Text
    , failed_when : Optional Text
    , debug : Optional ({ msg : Text })
  }
    , default =
        { name = None Text
    , file = None ({ name : Text, state : Text })
    , when = None Text
    , run_once = None Bool
    , check_mode = None Bool
    , delegate_to = None Text
    , delegate_facts = None Bool
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ watchexec_version : Text, cacheable : Bool }) }))
    , apt = None ({ deb : Text })
    , shell = None Text
    , changed_when = None Bool
    , register = None Text
    , failed_when = None Text
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      name = Some "Remove /usr/local/sbin/watchexec",
      file = Some { name = "/usr/local/sbin/watchexec", state = "absent" }
    }
  , Item::{
      when = Some "watchexec_version is not defined",
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of watchexec",
          github_release = Some { user = "watchexec", repo = "watchexec", action = "latest_release" },
          register = Some "gr",
          set_fact = None ({ watchexec_version : Text, cacheable : Bool })
        }
      , {
          name = "Set watchexec_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { watchexec_version = "{{ gr.tag.lstrip('v') }}", cacheable = True }
        }
    ]
    }
  , Item::{
      name = Some "Install watchexec",
      apt = Some { deb = "{{ watchexec_url_map[watchexec_architecture] }}" }
    }
  , Item::{
      name = Some "Check that watchexec is executable and the correct version",
      shell = Some "watchexec --version | awk 'NR == 1 { print $2 }'",
      changed_when = Some False,
      register = Some "_r",
      failed_when = Some "not _r.stdout.endswith(watchexec_version)"
    }
  , Item::{
      name = Some "Which version of watchexec was installed",
      debug = Some { msg = "Installed {{ watchexec_version }}" }
    }
]
