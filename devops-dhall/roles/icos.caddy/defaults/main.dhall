-- Auto-generated from ../../../../devops/roles/icos.caddy/defaults/main.yml

{
    caddy_global_conf = ''
    :80 {
      respond "Not found." 404
    }

  ''
  , caddy_site_state = "present"
  , caddy_modules = [] : List Text
  , caddy_dropin_path = "/etc/systemd/system/caddy.service.d/usr_local_bin.conf"
  , caddy_via_xcaddy = "/usr/local/bin/caddy"
  , caddy_bin = "{{ caddy_via_xcaddy if caddy_modules else '/usr/bin/caddy' }}"
  , caddy_upgrade = "{{ upgrade_everything | default(False) | bool }}"
  , xcaddy_upgrade = "{{ caddy_upgrade }}"
}
