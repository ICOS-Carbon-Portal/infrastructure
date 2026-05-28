-- Auto-generated from main.yml

{
    dnsmasq_hosts = None Text
  , dnsmasq_config_name = "config"
  , dnsmasq_config_state = "present"
  , dnsmasq_config_dir = "/etc/dnsmasq.{{ dnsmasq_instance }}.d"
  , dnsmasq_config_file = "{{ dnsmasq_config_dir }}/{{ dnsmasq_config_name }}"
  , dnsmasq_service_name = "dnsmasq@{{ dnsmasq_instance }}.service"
}
