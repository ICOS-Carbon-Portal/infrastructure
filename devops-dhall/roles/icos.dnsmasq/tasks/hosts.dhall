-- Auto-generated from hosts.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Populate /etc/hosts",
      blockinfile = Some {
        marker = "# {mark} ansible / dnsmasq / {{ dnsmasq_config_name }}"
      , state = Some "{{ 'present' if dnsmasq_hosts else 'absent' }}"
      , create = Some False
      , insertafter = Some "EOF"
      , path = "/etc/hosts"
      , block = Some "{{ dnsmasq_hosts }}"
      , insertbefore = None Text
    }
    }
]
