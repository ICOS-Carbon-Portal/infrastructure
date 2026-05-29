-- Auto-generated from hosts.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add nebula hosts to /etc/hosts",
      blockinfile = Some {
        marker = "# {mark} ansible / nebula"
      , state = Some "{{ 'present' if nebula_hosts_enable else 'absent' }}"
      , create = Some False
      , insertafter = Some "EOF"
      , path = "/etc/hosts"
      , block = Some "{{ nebula_hosts_block if nebula_hosts_enable else omit }}"
      , insertbefore = None Text
    }
    }
]
