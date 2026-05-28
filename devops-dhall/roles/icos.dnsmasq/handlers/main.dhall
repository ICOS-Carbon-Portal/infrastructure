-- Auto-generated from main.yml

[
    {
      name = "dnsmasq restart"
    , systemd = { name = "{{ dnsmasq_service_name }}", state = "restarted" }
  }
]
