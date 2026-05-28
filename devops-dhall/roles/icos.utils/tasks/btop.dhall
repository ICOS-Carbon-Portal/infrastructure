-- Auto-generated from btop.yml

let Item =
    { Type =
        { when : Optional Text
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ btop_version : Text, cacheable : Bool }) }))
    , name : Optional Text
    , unarchive : Optional ({ remote_src : Bool, src : Text, dest : Text })
    , register : Optional Text
    , file : Optional ({ dest : Text, src : Text, state : Text })
    , shell : Optional Text
    , changed_when : Optional Bool
    , debug : Optional ({ msg : Text })
  }
    , default =
        { when = None Text
    , run_once = None Bool
    , check_mode = None Bool
    , delegate_to = None Text
    , delegate_facts = None Bool
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ btop_version : Text, cacheable : Bool }) }))
    , name = None Text
    , unarchive = None ({ remote_src : Bool, src : Text, dest : Text })
    , register = None Text
    , file = None ({ dest : Text, src : Text, state : Text })
    , shell = None Text
    , changed_when = None Bool
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      when = Some "btop_version is not defined",
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of btop",
          github_release = Some { user = "aristocratos", repo = "btop", action = "latest_release" },
          register = Some "gh",
          set_fact = None ({ btop_version : Text, cacheable : Bool })
        }
      , {
          name = "Set btop_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { btop_version = "{{ gh.tag.lstrip('v') }}", cacheable = True }
        }
    ]
    }
  , Item::{
      name = Some "Unarchive btop",
      unarchive = Some {
        remote_src = True
      , src = "{{ btop_url_map[ansible_architecture] }}"
      , dest = "/opt"
    },
      register = Some "unarchive"
    }
  , Item::{
      name = Some "Create /usr/local/bin/btop symlink",
      file = Some {
        dest = "/usr/local/bin/btop"
      , src = "{{ unarchive.dest }}/btop/bin/btop"
      , state = "link"
    }
    }
  , Item::{
      name = Some "Check that btop is executable",
      register = Some "_r",
      shell = Some "btop --version",
      changed_when = Some False
    }
  , Item::{
      name = Some "Which version of btop was installed",
      debug = Some { msg = "Installed {{ _r.stdout }}" }
    }
]
