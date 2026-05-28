-- Auto-generated from main.yml

let Item =
    { Type =
        { name : Optional Text
    , command : Optional Text
    , register : Optional Text
    , changed_when : Optional Bool
    , when : Optional Text
    , become : Optional Text
    , become_user : Optional Text
    , block : Optional (List ({ name : Text, get_url : Optional ({ url : Text, dest : Text }), register : Optional Text, command : Optional Text, changed_when : Optional Bool, shell : Optional Text }))
    , template : Optional ({ src : Text, dest : Text, mode : Natural })
    , failed_when : Optional Bool
    , `assert` : Optional ({ that : Text })
  }
    , default =
        { name = None Text
    , command = None Text
    , register = None Text
    , changed_when = None Bool
    , when = None Text
    , become = None Text
    , become_user = None Text
    , block = None (List ({ name : Text, get_url : Optional ({ url : Text, dest : Text }), register : Optional Text, command : Optional Text, changed_when : Optional Bool, shell : Optional Text }))
    , template = None ({ src : Text, dest : Text, mode : Natural })
    , failed_when = None Bool
    , `assert` = None ({ that : Text })
  }
    }

in  [
    Item::{
      name = Some "List docker images matching the stiltrun image",
      command = Some "docker images -qa {{stiltrun_image_name}}",
      register = Some "docker_images",
      changed_when = Some False
    }
  , Item::{
      when = Some "stiltrun_image_id not in docker_images.stdout",
      become = Some "{{ stiltrun_user != \"root\" }}",
      become_user = Some "{{ stiltrun_user }}",
      block = Some [
        {
          name = "Download stilt docker image",
          get_url = Some { url = "{{ stiltrun_image_url }}", dest = "/tmp" },
          register = Some "_get_url",
          command = None Text,
          changed_when = None Bool,
          shell = None Text
        }
      , {
          name = "Load stilt image into docker",
          get_url = None ({ url : Text, dest : Text }),
          register = None Text,
          command = Some "docker load -i \"{{ _get_url.dest }}\"",
          changed_when = Some False,
          shell = None Text
        }
      , {
          name = "Check that stiltrun_image was properly loaded",
          get_url = None ({ url : Text, dest : Text }),
          register = None Text,
          command = None Text,
          changed_when = Some False,
          shell = Some "docker images -q | grep {{ stiltrun_image_id }} -q"
        }
      , {
          name = "Tag the stiltrun image",
          get_url = None ({ url : Text, dest : Text }),
          register = None Text,
          command = None Text,
          changed_when = Some False,
          shell = Some "docker tag {{stiltrun_image_id}} {{stiltrun_image_name}}"
        }
    ]
    }
  , Item::{
      name = Some "Install the stilt python wrapper",
      register = Some "_stilt_py",
      template = Some { src = "stilt.py", dest = "/usr/local/bin/stilt", mode = 493 }
    }
  , Item::{
      name = Some "Test stiltrun by running listmetfiles",
      command = Some "{{ _stilt_py.dest }} listmetfiles",
      changed_when = Some False
    }
  , Item::{
      name = Some "Test stiltrun by running calcslots",
      command = Some "{{ _stilt_py.dest }} calcslots 2012010100 2012010106",
      register = Some "stilt_output",
      changed_when = Some False,
      failed_when = Some False
    }
  , Item::{
      name = Some "Check the output of calcslots",
      changed_when = Some False,
      `assert` = Some { that = "stilt_output.stdout == \"2012010100\\n2012010103\\n2012010106\"" }
    }
]
