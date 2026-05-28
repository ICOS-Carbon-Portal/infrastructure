-- Auto-generated from hosts.yml

[
    {
      name = "Populate /etc/hosts"
    , blockinfile = {
        marker = "# {mark} ansible / dnsmasq / {{ dnsmasq_config_name }}"
      , state = "{{ 'present' if dnsmasq_hosts else 'absent' }}"
      , create = False
      , insertafter = "EOF"
      , path = "/etc/hosts"
      , block = "{{ dnsmasq_hosts }}"
    }
  }
]
