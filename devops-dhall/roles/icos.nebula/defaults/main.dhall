-- Auto-generated from main.yml

{
    nebula_is_lighthouse = False
  , nebula_interface = "nebula"
  , nebula_domain = "nebula"
  , nebula_cert_copy = "{{ nebula_cert_sign }}"
  , nebula_etc_dir = "/etc/nebula"
  , nebula_bin_dir = "/usr/local/bin"
  , nebula_user = "nebula"
  , nebula_port = 4242
  , nebula_hosts_block = None Text
  , nebula_hosts_enable = True
  , nebula_fw_enable = True
  , nebula_hostname = "{{ inventory_hostname_short }}"
  , nebula_upgrade = "{{ upgrade_everything | default(False) | bool }}"
  , nebula_ca_path = "{{ nebula_cert_files }}/ca.crt"
  , nebula_cert_min_days = 90
  , nebula_stats_enable = False
  , nebula_stats_port = 2735
  , nebula_resolve_enable = False
  , nebula_resolve_type = "probe"
  , nebula_resolve_servers = None Text
  , nebula_resolve_test = None Text
  , nebula_ssh_enable = False
  , nebula_ssh_key = "{{ nebula_etc_dir }}/admin"
  , nebula_ssh_port = 2346
  , nebula_version = "{{ hostvars.localhost.nebula_version }}"
  , nebula_url_map = {
      armv6l = "https://github.com/slackhq/nebula/releases/download/v{{ nebula_version }}/nebula-linux-arm-6.tar.gz"
    , armv7l = "https://github.com/slackhq/nebula/releases/download/v{{  nebula_version }}/nebula-linux-arm-7.tar.gz"
    , x86_64 = "https://github.com/slackhq/nebula/releases/download/v{{  nebula_version }}/nebula-linux-amd64.tar.gz"
    , aarch64 = "https://github.com/slackhq/nebula/releases/download/v{{  nebula_version }}/nebula-linux-arm64.tar.gz"
  }
}
