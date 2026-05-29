-- Auto-generated from ../../../../devops/roles/icos.telegraf/defaults/main.yml

{
    telegraf_config_root = "/etc/telegraf"
  , telegraf_config_file = "telegraf.conf"
  , telegraf_config_state = "present"
  , telegraf_config = ""
  , telegraf_upgrade = "{{ upgrade_everything | default(False) | bool }}"
  , telegraf_smart_enable = False
}
