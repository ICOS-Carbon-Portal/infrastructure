-- Auto-generated from install.yml

let Item =
    { Type =
        { when : Optional Text
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ restic_server_version : Text, cacheable : Bool }) }))
    , name : Optional Text
    , unarchive : Optional ({ remote_src : Bool, src : Text, dest : Text, mode : Text, include : List Text, extra_opts : List Text })
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
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ restic_server_version : Text, cacheable : Bool }) }))
    , name = None Text
    , unarchive = None ({ remote_src : Bool, src : Text, dest : Text, mode : Text, include : List Text, extra_opts : List Text })
    , shell = None Text
    , changed_when = None Bool
    , register = None Text
    , failed_when = None Text
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      when = Some "restic_server_version is not defined",
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of restic_server",
          github_release = Some { user = "restic", repo = "rest-server", action = "latest_release" },
          register = Some "gh",
          set_fact = None ({ restic_server_version : Text, cacheable : Bool })
        }
      , {
          name = "Set restic_server_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { restic_server_version = "{{ gh.tag.lstrip('v') }}", cacheable = True }
        }
    ]
    }
  , Item::{
      name = Some "Install restic_server",
      unarchive = Some {
        remote_src = True
      , src = "{{ restic_server_url_map[restic_server_architecture] }}"
      , dest = "{{ restic_server_home }}/bin/"
      , mode = "+x"
      , include = [ "*/rest-server" ]
      , extra_opts = [ "--no-same-owner", "--strip-components=1", "--wildcards" ]
    }
    }
  , Item::{
      name = Some "Check that restic_server is executable and the correct version",
      shell = Some "{{ restic_server_exec }} --version",
      changed_when = Some False,
      register = Some "_r",
      failed_when = Some "restic_server_version not in _r.stdout"
    }
  , Item::{
      name = Some "Which version of restic_server was installed",
      debug = Some { msg = "Installed {{ restic_server_version }}" }
    }
]
