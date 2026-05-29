-- Auto-generated from rename-lxd.yml

[
    {
      hosts = "cdb"
    , vars = {
        old_name = "pgrep-rdflog"
      , new_name = "pgrep2"
      , ssh_port = "{{ hostvars[new_name].ansible_port }}"
    }
    , tasks = [
        {
          name = Some "stop container",
          command = Some "lxc stop {{ old_name }}",
          register = Some "r",
          failed_when = Some [ "r.rc != 0", "'not found' not in r.stderr.lower()" ],
          changed_when = Some [ "r.rc == 0" ],
          lineinfile = None ({ path : Text, regex : Text, line : Text, state : Text, backrefs : Bool }),
          iptables_raw = None ({ name : Text, state : Optional Text, table : Text, rules : Optional Text }),
          shell = None Text,
          debug = None ({ msg : Text })
        }
      , {
          name = Some "rename container",
          command = Some "lxc rename {{ old_name }} {{ new_name }}",
          register = Some "r",
          failed_when = Some [ "r.rc != 0", "'not found' not in r.stderr.lower()" ],
          changed_when = Some [ "r.rc == 0" ],
          lineinfile = None ({ path : Text, regex : Text, line : Text, state : Text, backrefs : Bool }),
          iptables_raw = None ({ name : Text, state : Optional Text, table : Text, rules : Optional Text }),
          shell = None Text,
          debug = None ({ msg : Text })
        }
      , {
          name = Some "Modify /etc/hosts",
          command = None Text,
          register = Some "r",
          failed_when = None (List Text),
          changed_when = None (List Text),
          lineinfile = Some {
            path = "/etc/hosts"
          , regex = "(\\S*)\\s+(?:{{ old_name }})\\.lxd$"
          , line = "\\1\\t{{ new_name }}.lxd"
          , state = "present"
          , backrefs = True
        },
          iptables_raw = None ({ name : Text, state : Optional Text, table : Text, rules : Optional Text }),
          shell = None Text,
          debug = None ({ msg : Text })
        }
      , {
          name = Some "Remove old iptables rule",
          command = None Text,
          register = None Text,
          failed_when = None (List Text),
          changed_when = None (List Text),
          lineinfile = None ({ path : Text, regex : Text, line : Text, state : Text, backrefs : Bool }),
          iptables_raw = Some {
            name = "forward_ssh_to_{{ old_name }}"
          , state = Some "absent"
          , table = "nat"
          , rules = None Text
        },
          shell = None Text,
          debug = None ({ msg : Text })
        }
      , {
          name = Some "Get ip of host",
          command = None Text,
          register = Some "ip",
          failed_when = None (List Text),
          changed_when = Some False,
          lineinfile = None ({ path : Text, regex : Text, line : Text, state : Text, backrefs : Bool }),
          iptables_raw = None ({ name : Text, state : Optional Text, table : Text, rules : Optional Text }),
          shell = Some "awk '/{{ new_name }}/ {print $1}' < /etc/hosts",
          debug = None ({ msg : Text })
        }
      , {
          name = Some "Add new forwarding rule",
          command = None Text,
          register = None Text,
          failed_when = None (List Text),
          changed_when = None (List Text),
          lineinfile = None ({ path : Text, regex : Text, line : Text, state : Text, backrefs : Bool }),
          iptables_raw = Some {
            name = "forward_ssh_to_{{ new_name }}"
          , state = None Text
          , table = "nat"
          , rules = Some "-A PREROUTING -p tcp --dport {{ ssh_port }} -j DNAT --to-destination {{ ip.stdout }}:22"
        },
          shell = None Text,
          debug = None ({ msg : Text })
        }
      , {
          name = Some "start container",
          command = Some "lxc start {{ new_name }}",
          register = None Text,
          failed_when = None (List Text),
          changed_when = None (List Text),
          lineinfile = None ({ path : Text, regex : Text, line : Text, state : Text, backrefs : Bool }),
          iptables_raw = None ({ name : Text, state : Optional Text, table : Text, rules : Optional Text }),
          shell = None Text,
          debug = None ({ msg : Text })
        }
      , {
          name = None Text,
          command = None Text,
          register = None Text,
          failed_when = None (List Text),
          changed_when = None (List Text),
          lineinfile = None ({ path : Text, regex : Text, line : Text, state : Text, backrefs : Bool }),
          iptables_raw = None ({ name : Text, state : Optional Text, table : Text, rules : Optional Text }),
          shell = None Text,
          debug = Some {
            msg = ''
            If we're on zfs, maybe rename the docker storage?

          ''
        }
        }
    ]
  }
]
