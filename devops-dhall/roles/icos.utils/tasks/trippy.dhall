-- Auto-generated from trippy.yml

let Item =
    { Type =
        { when : Optional Text
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ trippy_version : Text, cacheable : Bool }) }))
    , name : Optional Text
    , unarchive : Optional ({ remote_src : Bool, src : Text, dest : Text, extra_opts : List Text })
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
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ trippy_version : Text, cacheable : Bool }) }))
    , name = None Text
    , unarchive = None ({ remote_src : Bool, src : Text, dest : Text, extra_opts : List Text })
    , shell = None Text
    , changed_when = None Bool
    , register = None Text
    , failed_when = None Text
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      when = Some "trippy_version is not defined",
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of trippy",
          github_release = Some { user = "fujiapple852", repo = "trippy", action = "latest_release" },
          register = Some "gh",
          set_fact = None ({ trippy_version : Text, cacheable : Bool })
        }
      , {
          name = "Set trippy_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { trippy_version = "{{ gh.tag.lstrip('v') }}", cacheable = True }
        }
    ]
    }
  , Item::{
      name = Some "Install trippy",
      unarchive = Some {
        remote_src = True
      , src = "{{ trippy_url_map[ansible_architecture] }}"
      , dest = "/usr/local/bin"
      , extra_opts = [ "--strip-components=1" ]
    }
    }
  , Item::{
      name = Some "Check that trippy is executable and the correct version",
      shell = Some "trip --version",
      changed_when = Some False,
      register = Some "_r",
      failed_when = Some "not _r.stdout.endswith(trippy_version)"
    }
  , Item::{
      name = Some "Which version of trippy was installed",
      debug = Some { msg = "Installed {{ trippy_version }}" }
    }
]
