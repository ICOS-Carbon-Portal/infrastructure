-- Auto-generated from install.yml

let Item =
    { Type =
        { when : Optional Text
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ just_version : Text, cacheable : Bool }) }))
    , name : Optional Text
    , unarchive : Optional ({ remote_src : Bool, src : Text, dest : Text, include : List Text })
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
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ just_version : Text, cacheable : Bool }) }))
    , name = None Text
    , unarchive = None ({ remote_src : Bool, src : Text, dest : Text, include : List Text })
    , shell = None Text
    , changed_when = None Bool
    , register = None Text
    , failed_when = None Text
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      when = Some "just_version is not defined",
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of just",
          github_release = Some { user = "casey", repo = "just", action = "latest_release" },
          register = Some "gh",
          set_fact = None ({ just_version : Text, cacheable : Bool })
        }
      , {
          name = "Set just_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { just_version = "{{ gh.tag.lstrip('v') }}", cacheable = True }
        }
    ]
    }
  , Item::{
      name = Some "Install just",
      unarchive = Some {
        remote_src = True
      , src = "{{ just_url_map[ansible_architecture] }}"
      , dest = "/usr/local/bin"
      , include = [ "just" ]
    }
    }
  , Item::{
      name = Some "Check that just is executable and the correct version",
      shell = Some "just --version",
      changed_when = Some False,
      register = Some "_r",
      failed_when = Some "not _r.stdout.endswith(just_version)"
    }
  , Item::{
      name = Some "Which version of just was installed",
      debug = Some { msg = "Installed {{ just_version }}" }
    }
]
