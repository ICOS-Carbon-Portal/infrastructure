-- Auto-generated from ripgrep.yml

let Item =
    { Type =
        { when : Optional (List Text)
    , run_once : Optional Bool
    , check_mode : Optional Bool
    , delegate_to : Optional Text
    , delegate_facts : Optional Bool
    , block : Optional (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ ripgrep_version : Text, cacheable : Bool }), apt : Optional ({ name : List Text }) }))
    , name : Optional Text
    , apt : Optional ({ deb : Text })
    , shell : Optional Text
    , changed_when : Optional Bool
    , register : Optional Text
    , debug : Optional ({ msg : Text })
  }
    , default =
        { when = None (List Text)
    , run_once = None Bool
    , check_mode = None Bool
    , delegate_to = None Text
    , delegate_facts = None Bool
    , block = None (List ({ name : Text, github_release : Optional ({ user : Text, repo : Text, action : Text }), register : Optional Text, set_fact : Optional ({ ripgrep_version : Text, cacheable : Bool }), apt : Optional ({ name : List Text }) }))
    , name = None Text
    , apt = None ({ deb : Text })
    , shell = None Text
    , changed_when = None Bool
    , register = None Text
    , debug = None ({ msg : Text })
  }
    }

in  [
    Item::{
      when = Some [ "ansible_architecture == \"x86_64\"", "ripgrep_version is not defined" ],
      run_once = Some True,
      check_mode = Some False,
      delegate_to = Some "localhost",
      delegate_facts = Some True,
      block = Some [
        {
          name = "Find the latest release of ripgrep",
          github_release = Some { user = "BurntSushi", repo = "ripgrep", action = "latest_release" },
          register = Some "gh",
          set_fact = None ({ ripgrep_version : Text, cacheable : Bool }),
          apt = None ({ name : List Text })
        }
      , {
          name = "Set ripgrep_version fact",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = Some { ripgrep_version = "{{ gh.tag.lstrip('v') }}", cacheable = True },
          apt = None ({ name : List Text })
        }
    ]
    }
  , Item::{
      when = Some [ "ansible_architecture == \"x86_64\"" ],
      name = Some "Install ripgrep using .deb from github",
      apt = Some { deb = "{{ ripgrep_url_map[ansible_architecture] }}" }
    }
  , Item::{
      when = Some [ "ansible_architecture != \"x86_64\"" ],
      block = Some [
        {
          name = "Install ripgrep using apt",
          github_release = None ({ user : Text, repo : Text, action : Text }),
          register = None Text,
          set_fact = None ({ ripgrep_version : Text, cacheable : Bool }),
          apt = Some { name = [ "ripgrep" ] }
        }
    ]
    }
  , Item::{
      name = Some "Check that ripgrep is executable",
      shell = Some "rg --version | head -1",
      changed_when = Some False,
      register = Some "_version"
    }
  , Item::{
      name = Some "Which version of ripgrep was installed",
      debug = Some { msg = "Installed {{ _version.stdout }}" }
    }
]
