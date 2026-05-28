-- Auto-generated from install.yml

let Item =
    { Type =
        { when : Optional Text
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ borg_version : Text, cacheable : Bool }) }))
    , name : Optional Text
    , fail : Optional ({ msg : Text })
    , get_url : Optional ({ url : Text, dest : Text, force : Text, mode : Text })
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
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ borg_version : Text, cacheable : Bool }) }))
    , name = None Text
    , fail = None ({ msg : Text })
    , get_url = None ({ url : Text, dest : Text, force : Text, mode : Text })
    , shell = None Text
    , changed_when = None Bool
    , register = None Text
    , failed_when = None Text
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      when = Some "borg_version is not defined",
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of borg",
          github_release = Some { user = "borgbackup", repo = "borg", action = "latest_release" },
          register = Some "gh",
          set_fact = None ({ borg_version : Text, cacheable : Bool })
        }
      , {
          name = "Set borg_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { borg_version = "{{ gh.tag.lstrip('v') }}", cacheable = True }
        }
    ]
    }
  , Item::{
      when = Some "ansible_architecture in (\"armv6l\", \"armv7l\", \"aarch64\")",
      name = Some "Architecture is not supported",
      fail = Some { msg = "borg is not supported on {{ ansible_architecture }}" }
    }
  , Item::{
      name = Some "Download borg",
      get_url = Some {
        url = "{{ borg_url_map[ansible_architecture] }}"
      , dest = "{{ borg_bin }}"
      , force = "{{ borg_upgrade }}"
      , mode = "+x"
    }
    }
  , Item::{
      name = Some "Check that borg is executable and the correct version",
      shell = Some "{{ borg_bin }} --version",
      changed_when = Some False,
      register = Some "_r",
      failed_when = Some "not _r.stdout.endswith(borg_version)"
    }
  , Item::{
      name = Some "Which version of borg is installed",
      debug = Some { msg = "Installed {{ borg_version }}" }
    }
]
