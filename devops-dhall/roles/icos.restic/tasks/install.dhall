-- Auto-generated from install.yml

let Item =
    { Type =
        { when : Optional Text
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ restic_version : Text, cacheable : Bool }) }))
    , name : Optional Text
    , `ansible.builtin.shell` : Optional Text
    , args : Optional ({ creates : Text, executable : Text })
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
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ restic_version : Text, cacheable : Bool }) }))
    , name = None Text
    , `ansible.builtin.shell` = None Text
    , args = None ({ creates : Text, executable : Text })
    , shell = None Text
    , changed_when = None Bool
    , register = None Text
    , failed_when = None Text
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      when = Some "restic_version is not defined",
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of restic",
          github_release = Some { user = "restic", repo = "restic", action = "latest_release" },
          register = Some "gh",
          set_fact = None ({ restic_version : Text, cacheable : Bool })
        }
      , {
          name = "Set restic_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { restic_version = "{{ gh.tag.lstrip('v') }}", cacheable = True }
        }
    ]
    }
  , Item::{
      name = Some "Download restic",
      `ansible.builtin.shell` = Some "curl -L --silent {{ restic_url_map[restic_architecture] }} | bunzip2 > /usr/local/bin/restic && chmod +x /usr/local/bin/restic",
      args = Some {
        creates = "{{ omit if restic_upgrade else '/usr/local/bin/restic' }}"
      , executable = "/bin/bash"
    }
    }
  , Item::{
      name = Some "Check that restic is executable and the correct version",
      shell = Some "restic version",
      changed_when = Some False,
      register = Some "_r",
      failed_when = Some "restic_version not in _r.stdout"
    }
  , Item::{
      name = Some "Which version of restic was installed",
      debug = Some { msg = "Installed {{ restic_version }}" }
    }
]
