-- Auto-generated from ../../devops/fixes/rename-lxd.yml

let Task = ../types/Task.dhall

in  [
    {
      hosts = "cdb"
    , vars = {
        old_name = "pgrep-rdflog"
      , new_name = "pgrep2"
      , ssh_port = "{{ hostvars[new_name].ansible_port }}"
    }
    , tasks = [
        Task::{
          name = Some "stop container",
          command = Some "lxc stop {{ old_name }}",
          register = Some "r",
          failed_when = Some (Task.Poly_failed_when.Texts [ "r.rc != 0", "'not found' not in r.stderr.lower()" ]),
          changed_when = Some (Task.Poly_changed_when.Texts [ "r.rc == 0" ])
        }
      , Task::{
          name = Some "rename container",
          command = Some "lxc rename {{ old_name }} {{ new_name }}",
          register = Some "r",
          failed_when = Some (Task.Poly_failed_when.Texts [ "r.rc != 0", "'not found' not in r.stderr.lower()" ]),
          changed_when = Some (Task.Poly_changed_when.Texts [ "r.rc == 0" ])
        }
      , Task::{
          name = Some "Modify /etc/hosts",
          lineinfile = Some {
            path = "/etc/hosts",
            regex = Some "(\\S*)\\s+(?:{{ old_name }})\\.lxd$",
            line = Some "\\1\\t{{ new_name }}.lxd",
            state = Some "present",
            backrefs = Some True,
            regexp = None Text,
            create = None Bool,
            owner = None Text,
            group = None Text,
            insertafter = None Text,
            mode = None Natural,
            insertbefore = None Text
        },
          register = Some "r"
        }
      , Task::{
          name = Some "Remove old iptables rule",
          iptables_raw = Some {
            name = "forward_ssh_to_{{ old_name }}",
            rules = None Text,
            table = Some "nat",
            state = Some "absent",
            weight = None Natural
        }
        }
      , Task::{
          name = Some "Get ip of host",
          shell = Some "awk '/{{ new_name }}/ {print $1}' < /etc/hosts",
          changed_when = Some (Task.Poly_changed_when.Bool False),
          register = Some "ip"
        }
      , Task::{
          name = Some "Add new forwarding rule",
          iptables_raw = Some {
            name = "forward_ssh_to_{{ new_name }}",
            rules = Some "-A PREROUTING -p tcp --dport {{ ssh_port }} -j DNAT --to-destination {{ ip.stdout }}:22",
            table = Some "nat",
            state = None Text,
            weight = None Natural
        }
        }
      , Task::{ name = Some "start container", command = Some "lxc start {{ new_name }}" }
      , Task::{
          debug = Some (Task.Poly_debug.Record {
              msg = ''
              If we're on zfs, maybe rename the docker storage?

            ''
          })
        }
    ]
  }
]
