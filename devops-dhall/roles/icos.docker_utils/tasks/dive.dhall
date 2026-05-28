-- Auto-generated from dive.yml

let Item =
    { Type =
        { when : Optional Text
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ dive_version : Text, cacheable : Bool }) }))
    , name : Optional Text
    , file : Optional ({ name : Text, state : Text })
    , apt : Optional ({ deb : Text })
    , shell : Optional Text
    , changed_when : Optional Bool
    , register : Optional Text
    , failed_when : Optional Text
    , debug : Optional ({ msg : Text })
  }
    , default =
        { when = None Text
    , run_once = None Bool
    , check_mode = None Bool
    , delegate_to = None Text
    , delegate_facts = None Bool
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ dive_version : Text, cacheable : Bool }) }))
    , name = None Text
    , file = None ({ name : Text, state : Text })
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
      when = Some "dive_version is not defined",
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of dive",
          github_release = Some { user = "wagoodman", repo = "dive", action = "latest_release" },
          register = Some "gh",
          set_fact = None ({ dive_version : Text, cacheable : Bool })
        }
      , {
          name = "Set dive_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { dive_version = "{{ gh.tag.lstrip('v') }}", cacheable = True }
        }
    ]
    }
  , Item::{
      name = Some "Remove old install of /usr/local/sbin/dive",
      file = Some { name = "/usr/local/sbin/dive", state = "absent" }
    }
  , Item::{
      name = Some "Install dive",
      apt = Some { deb = "{{ dive_url_map[dive_architecture] }}" }
    }
  , Item::{
      name = Some "Check that dive is executable and the correct version",
      shell = Some "dive --version",
      changed_when = Some False,
      register = Some "_r",
      failed_when = Some "not _r.stdout.endswith(dive_version)"
    }
  , Item::{
      name = Some "Which version of dive was installed",
      debug = Some { msg = "Installed {{ dive_version }}" }
    }
]
