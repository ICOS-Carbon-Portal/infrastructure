-- Auto-generated from ../../../../devops/roles/icos.nebula/tasks/hosts.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Add nebula hosts to /etc/hosts",
      blockinfile = Some {
        path = "/etc/hosts",
        create = Some False,
        marker = "# {mark} ansible / nebula",
        block = Some "{{ nebula_hosts_block if nebula_hosts_enable else omit }}",
        insertafter = Some "EOF",
        insertbefore = None Text,
        state = Some "{{ 'present' if nebula_hosts_enable else 'absent' }}"
    }
    }
]
