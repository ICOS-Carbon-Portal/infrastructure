-- Auto-generated from lazydocker.yml

let Item =
    { Type =
        { when : Optional Text
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ lazydocker_version : Text, cacheable : Bool }) }))
    , name : Optional Text
    , file : Optional ({ name : Text, state : Text })
    , unarchive : Optional ({ owner : Text, group : Text, remote_src : Bool, src : Text, dest : Text, include : List Text })
    , register : Optional Text
    , debug : Optional ({ msg : Text })
    , shell : Optional Text
    , changed_when : Optional Bool
    , failed_when : Optional Text
  }
    , default =
        { when = None Text
    , run_once = None Bool
    , check_mode = None Bool
    , delegate_to = None Text
    , delegate_facts = None Bool
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ lazydocker_version : Text, cacheable : Bool }) }))
    , name = None Text
    , file = None ({ name : Text, state : Text })
    , unarchive = None ({ owner : Text, group : Text, remote_src : Bool, src : Text, dest : Text, include : List Text })
    , register = None Text
    , debug = None ({ msg : Text })
    , shell = None Text
    , changed_when = None Bool
    , failed_when = None Text
  }
    }

in  [
    Item::{
      when = Some "lazydocker_version is not defined",
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of lazydocker",
          github_release = Some { user = "jesseduffield", repo = "lazydocker", action = "latest_release" },
          register = Some "gh",
          set_fact = None ({ lazydocker_version : Text, cacheable : Bool })
        }
      , {
          name = "Set lazydocker_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { lazydocker_version = "{{ gh.tag.lstrip('v') }}", cacheable = True }
        }
    ]
    }
  , Item::{
      name = Some "Remove old install of /usr/local/sbin/lazydocker",
      file = Some { name = "/usr/local/sbin/lazydocker", state = "absent" }
    }
  , Item::{
      name = Some "Install lazydocker",
      unarchive = Some {
        owner = "root"
      , group = "root"
      , remote_src = True
      , src = "{{ lazydocker_url_map[lazydocker_architecture] }}"
      , dest = "/usr/local/bin"
      , include = [ "lazydocker" ]
    },
      register = Some "_unarchive"
    }
  , Item::{
      name = Some "Which version of lazydocker was installed",
      debug = Some { msg = "Installed {{ lazydocker_version }}" }
    }
  , Item::{
      name = Some "Check that lazydocker is executable and the correct version",
      register = Some "_r",
      shell = Some "lazydocker --version",
      changed_when = Some False,
      failed_when = Some "not _r.stdout_lines[0].endswith(lazydocker_version)"
    }
]
