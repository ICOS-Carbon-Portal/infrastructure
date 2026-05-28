-- Auto-generated from site.yml

let Item =
    { Type =
        { name : Optional Text
    , file : Optional ({ dest : Text, state : Text })
    , loop : Optional (List Text)
    , import_tasks : Optional Text
    , vars : Optional ({ block : Text, marker : Text, state : Text, where : Text })
  }
    , default =
        { name = None Text
    , file = None ({ dest : Text, state : Text })
    , loop = None (List Text)
    , import_tasks = None Text
    , vars = None ({ block : Text, marker : Text, state : Text, where : Text })
  }
    }

in  [
    Item::{
      name = Some "Remove old caddy config files",
      file = Some { dest = "{{ item }}", state = "absent" },
      loop = Some [
        "/etc/caddy/sites/Caddyfile.{{ caddy_name }}"
      , "/etc/caddy/{{ caddy_name }}.caddy"
    ]
    }
  , Item::{
      import_tasks = Some "config.yml",
      vars = Some {
        block = "{{ caddy_conf }}"
      , marker = "{{ caddy_name }}"
      , state = "{{ caddy_site_state }}"
      , where = "EOF"
    }
    }
]
