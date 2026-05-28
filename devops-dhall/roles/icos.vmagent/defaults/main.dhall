-- Auto-generated from main.yml

{
    vmagent_home = "/opt/vmagent"
  , vmagent_fsd = "{{ vmagent_home }}/file_sd_configs"
  , vmagent_bin = "{{ vmagent_home }}/bin"
  , vmagent_configs = "{{ vmagent_home }}/configs"
  , vmagent_environ = "{{ vmagent_home }}/environ"
  , vmagent_conf = ''
    # We'll dynamically (using ansible and scripts) create config files and then
    # reload them by HUP:ing vmagent.
    scrape_config_files:
    - configs/*.yaml

    # Also support File Service Discovery.
    scrape_configs:
    - job_name: file
      file_sd_configs:
      - files:
        - "{{ vmagent_fsd }}/*.yaml"
        - "{{ vmagent_fsd }}/*.json"

  ''
  , vmagent_auth = None Text
  , vmagent_pathprefix = None Text
  , vmagent_listen = "127.0.0.1:8429"
  , vmagent_upgrade = "{{ upgrade_everything | default(False) | bool }}"
  , vmagent_arch = "{{ vmagent_arch_map[ansible_architecture] }}"
  , vmagent_arch_map = { armv7l = "arm", armv6l = "arm", x86_64 = "amd64" }
  , fsd_host = "{{ ansible_hostname | splitext | first }}"
  , vmagent_proxy = "disabled"
  , nginxsite_name = "vmagent"
  , nginxsite_file = "vmagent-nginx.conf"
  , nginxsite_users = [ "{{ vault_vmagent_auth }}" ]
  , nginxsite_domains = [ "{{ inventory_hostname }}" ]
  , caddy_name = "vmagent"
  , caddy_conf = "{{ lookup('template', 'vmagent-caddy.conf') }}"
}
