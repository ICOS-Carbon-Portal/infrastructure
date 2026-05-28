-- Auto-generated from config.yml

[
    {
      block = [
        {
          name = "Add caddy configuration block",
          blockinfile = Some {
            path = "/etc/caddy/Caddyfile"
          , block = "{{ block }}"
          , marker = "# {mark} {{ marker }}"
          , state = "{{ state | default(omit) }}"
          , backup = True
          , create = True
          , insertafter = "{{ 'EOF' if where == 'EOF' else omit }}"
          , insertbefore = "{{ 'BOF' if where == 'BOF' else omit }}"
        },
          register = Some "_r",
          command = None Text,
          args = None ({ chdir : Text }),
          changed_when = None Text,
          notify = None Text
        }
      , {
          name = "Run validation",
          blockinfile = None ({ path : Text, block : Text, marker : Text, state : Text, backup : Bool, create : Bool, insertafter : Text, insertbefore : Text }),
          register = None Text,
          command = Some "{{ caddy_bin }} validate",
          args = Some { chdir = "/etc/caddy" },
          changed_when = Some "_r.changed",
          notify = Some "reload caddy"
        }
    ]
    , rescue = [
        {
          name = "Slurp failed file and add line numbers",
          command = Some "cat -n /etc/caddy/Caddyfile",
          register = Some "_slurp",
          debug = None ({ msg : Text }),
          copy = None ({ remote_src : Bool, dest : Text, src : Text }),
          when = None Text
        }
      , {
          name = "Dump failed configuration",
          command = None Text,
          register = None Text,
          debug = Some { msg = "{{ _slurp.stdout }}" },
          copy = None ({ remote_src : Bool, dest : Text, src : Text }),
          when = None Text
        }
      , {
          name = "Restore config file",
          command = None Text,
          register = None Text,
          debug = None ({ msg : Text }),
          copy = Some { remote_src = True, dest = "/etc/caddy/Caddyfile", src = "{{ _r.backup_file }}" },
          when = Some "_r['backup_file'] is defined"
        }
    ]
    , always = [
        {
          name = "Remove backup file"
        , file = { name = "{{ _r.backup_file }}", state = "absent" }
        , changed_when = False
        , when = "_r['backup_file'] is defined"
      }
    ]
  }
]
