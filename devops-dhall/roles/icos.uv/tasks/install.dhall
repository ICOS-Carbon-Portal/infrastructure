-- Auto-generated from install.yml

let Item =
    { Type =
        { when : Optional Text
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ uv_version : Text, cacheable : Bool }) }))
    , name : Optional Text
    , unarchive : Optional ({ owner : Text, group : Text, remote_src : Bool, src : Text, dest : Text, extra_opts : List Text })
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
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ uv_version : Text, cacheable : Bool }) }))
    , name = None Text
    , unarchive = None ({ owner : Text, group : Text, remote_src : Bool, src : Text, dest : Text, extra_opts : List Text })
    , shell = None Text
    , changed_when = None Bool
    , register = None Text
    , failed_when = None Text
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      when = Some "uv_version is not defined",
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of uv",
          github_release = Some { user = "astral-sh", repo = "uv", action = "latest_release" },
          register = Some "gh",
          set_fact = None ({ uv_version : Text, cacheable : Bool })
        }
      , {
          name = "Set uv_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { uv_version = "{{ gh.tag.lstrip('v') }}", cacheable = True }
        }
    ]
    }
  , Item::{
      name = Some "Install uv",
      unarchive = Some {
        owner = "root"
      , group = "root"
      , remote_src = True
      , src = "{{ uv_url_map[uv_architecture] }}"
      , dest = "/usr/local/bin"
      , extra_opts = [ "--no-same-owner", "--strip-components=1" ]
    }
    }
  , Item::{
      name = Some "Check that uv is executable and the correct version",
      shell = Some "/usr/local/bin/uv version",
      changed_when = Some False,
      register = Some "_r",
      failed_when = Some "not _r.stdout.endswith(uv_version)"
    }
  , Item::{
      name = Some "Which version of uv was installed",
      debug = Some { msg = "Installed {{ uv_version }}" }
    }
]
