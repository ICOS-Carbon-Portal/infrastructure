-- Auto-generated from download.yml

let Item =
    { Type =
        { when : Optional Text
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ nebula_version : Text, cacheable : Bool }) }))
    , name : Optional Text
    , unarchive : Optional ({ remote_src : Bool, src : Text, dest : Text, extra_opts : List Text })
    , notify : Optional Text
  }
    , default =
        { when = None Text
    , run_once = None Bool
    , check_mode = None Bool
    , delegate_to = None Text
    , delegate_facts = None Bool
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ nebula_version : Text, cacheable : Bool }) }))
    , name = None Text
    , unarchive = None ({ remote_src : Bool, src : Text, dest : Text, extra_opts : List Text })
    , notify = None Text
  }
    }

in  [
    Item::{
      when = Some "nebula_version is not defined",
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of nebula",
          github_release = Some { user = "slackhq", repo = "nebula", action = "latest_release" },
          register = Some "gh",
          set_fact = None ({ nebula_version : Text, cacheable : Bool })
        }
      , {
          name = "Set nebula_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { nebula_version = "{{ gh.tag.lstrip('v') }}", cacheable = True }
        }
    ]
    }
  , Item::{
      name = Some "Install nebula",
      unarchive = Some {
        remote_src = True
      , src = "{{ nebula_url_map[ansible_architecture] }}"
      , dest = "{{ nebula_bin_dir }}"
      , extra_opts = [ "--no-same-owner" ]
    },
      notify = Some "restart nebula"
    }
]
