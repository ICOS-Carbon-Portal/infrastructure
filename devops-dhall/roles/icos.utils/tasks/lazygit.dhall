-- Auto-generated from lazygit.yml

let Item =
    { Type =
        { when : Optional Text
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ lazygit_version : Text, cacheable : Bool }) }))
    , name : Optional Text
    , unarchive : Optional ({ owner : Text, group : Text, remote_src : Bool, src : Text, dest : Text, include : List Text, extra_opts : List Text })
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
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ lazygit_version : Text, cacheable : Bool }) }))
    , name = None Text
    , unarchive = None ({ owner : Text, group : Text, remote_src : Bool, src : Text, dest : Text, include : List Text, extra_opts : List Text })
    , shell = None Text
    , changed_when = None Bool
    , register = None Text
    , failed_when = None Text
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      when = Some "lazygit_version is not defined",
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of lazygit",
          github_release = Some { user = "jesseduffield", repo = "lazygit", action = "latest_release" },
          register = Some "gh",
          set_fact = None ({ lazygit_version : Text, cacheable : Bool })
        }
      , {
          name = "Set lazygit_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { lazygit_version = "{{ gh.tag.lstrip('v') }}", cacheable = True }
        }
    ]
    }
  , Item::{
      name = Some "Install lazygit",
      unarchive = Some {
        owner = "root"
      , group = "root"
      , remote_src = True
      , src = "{{ lazygit_url_map[lazygit_architecture] }}"
      , dest = "/usr/local/bin/"
      , include = [ "lazygit" ]
      , extra_opts = [ "--no-same-owner", "--wildcards" ]
    }
    }
  , Item::{
      name = Some "Check that lazygit is executable and the correct version",
      shell = Some "/usr/local/bin/lazygit --version",
      changed_when = Some False,
      register = Some "_r",
      failed_when = Some "not lazygit_version in _r.stdout"
    }
  , Item::{
      name = Some "Which version of lazygit was installed",
      debug = Some { msg = "Installed {{ lazygit_version }}" }
    }
]
