-- Auto-generated from hosts.yml

[
    {
      name = "Add nebula hosts to /etc/hosts"
    , blockinfile = {
        marker = "# {mark} ansible / nebula"
      , create = False
      , insertafter = "EOF"
      , path = "/etc/hosts"
      , block = "{{ nebula_hosts_block if nebula_hosts_enable else omit }}"
      , state = "{{ 'present' if nebula_hosts_enable else 'absent' }}"
    }
  }
]
