-- Auto-generated from test.yml

let Task =
    { Type =
        { name : Text
    , shell : Optional Text
    , register : Optional Text
    , changed_when : Optional Bool
    , debug : Optional ({ msg : Text })
  }
    , default =
        { shell = None Text
    , register = None Text
    , changed_when = None Bool
    , debug = None ({ msg : Text })
  }
    }

in  [
    Task::{
      name = "Test that docker can pull and execute images",
      shell = Some ''
      docker run --rm alpine apk | grep -q coffee

    '',
      register = Some "_apk",
      changed_when = Some False
    }
  , Task::{
      name = "Report docker status",
      debug = Some {
        msg = ''
        Successfully ran an alpine image in {{ _apk.delta }}. It should take
        1-10 seconds, depending on whether the alpine image exists locally or
        not

      ''
    }
    }
]
