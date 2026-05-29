-- Auto-generated from ../../../../devops/roles/icos.jbuild/tasks/rsync.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Install rsync",
      apt = Some {
        name = Some [ "rsync" ],
        state = None Text,
        update_cache = None Bool,
        upgrade = None Text,
        deb = None Text,
        purge = None Bool,
        autoclean = None Bool,
        autoremove = None Bool,
        cache_valid_time = None Text,
        install_recommends = None Bool
    }
    }
  , Task::{
      name = Some "Add keys to authorized_keys",
      authorized_key = Some {
        user = "{{ jbuild_rsync_user }}",
        key = ''
        {% for elt in _jbuild_user_keys.results -%}
        {{ elt.public_key }}
        {% endfor %}

      '',
        state = None Text,
        exclusive = None Bool,
        key_options = Some "command=\"{{ jbuild_rrsync_bin }} /project/common\""
    }
    }
]
