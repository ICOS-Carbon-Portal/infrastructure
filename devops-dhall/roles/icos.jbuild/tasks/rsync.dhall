-- Auto-generated from rsync.yml

let Task =
    { Type =
        { name : Text
    , apt : Optional ({ name : List Text })
    , authorized_key : Optional ({ user : Text, key_options : Text, key : Text })
  }
    , default =
        { apt = None ({ name : List Text })
    , authorized_key = None ({ user : Text, key_options : Text, key : Text })
  }
    }

in  [
    Task::{ name = "Install rsync", apt = Some { name = [ "rsync" ] } }
  , Task::{
      name = "Add keys to authorized_keys",
      authorized_key = Some {
        user = "{{ jbuild_rsync_user }}"
      , key_options = "command=\"{{ jbuild_rrsync_bin }} /project/common\""
      , key = ''
        {% for elt in _jbuild_user_keys.results -%}
        {{ elt.public_key }}
        {% endfor %}

      ''
    }
    }
]
