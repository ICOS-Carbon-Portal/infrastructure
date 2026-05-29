-- Auto-generated from ../../../../devops/roles/icos.dnsmasq/tasks/hosts.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Populate /etc/hosts",
      blockinfile = Some {
        path = "/etc/hosts",
        create = Some False,
        marker = "# {mark} ansible / dnsmasq / {{ dnsmasq_config_name }}",
        block = Some "{{ dnsmasq_hosts }}",
        insertafter = Some "EOF",
        insertbefore = None Text,
        state = Some "{{ 'present' if dnsmasq_hosts else 'absent' }}"
    }
    }
]
