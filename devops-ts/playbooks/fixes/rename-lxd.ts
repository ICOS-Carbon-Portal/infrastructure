import { type Playbook, tmpl } from "../../lib/ansible.ts";

export default [
  {
    hosts: "cdb",
    vars: {
      old_name: "pgrep-rdflog",
      new_name: "pgrep2",
      ssh_port: tmpl("{{ hostvars[new_name].ansible_port }}"),
    },
    tasks: [
      {
        name: "stop container",
        command: tmpl("lxc stop {{ old_name }}"),
        register: "r",
        failed_when: ["r.rc != 0", "'not found' not in r.stderr.lower()"],
        changed_when: ["r.rc == 0"],
      },
      {
        name: "rename container",
        command: tmpl("lxc rename {{ old_name }} {{ new_name }}"),
        register: "r",
        failed_when: ["r.rc != 0", "'not found' not in r.stderr.lower()"],
        changed_when: ["r.rc == 0"],
      },
      {
        name: "Modify /etc/hosts",
        lineinfile: {
          path: "/etc/hosts",
          regex: tmpl("(\\S*)\\s+(?:{{ old_name }})\\.lxd$"),
          line: tmpl("\\1\\t{{ new_name }}.lxd"),
          state: "present",
          backrefs: true,
        },
        register: "r",
      },
      {
        name: "Remove old iptables rule",
        iptables_raw: {
          name: tmpl("forward_ssh_to_{{ old_name }}"),
          state: "absent",
          table: "nat",
        },
      },
      {
        name: "Get ip of host",
        shell: tmpl("awk '/{{ new_name }}/ {print $1}' < /etc/hosts"),
        changed_when: false,
        register: "ip",
      },
      {
        name: "Add new forwarding rule",
        iptables_raw: {
          name: tmpl("forward_ssh_to_{{ new_name }}"),
          table: "nat",
          rules: tmpl(
            "-A PREROUTING -p tcp --dport {{ ssh_port }} -j DNAT --to-destination {{ ip.stdout }}:22",
          ),
        },
      },
      {
        name: "start container",
        command: tmpl("lxc start {{ new_name }}"),
      },
      {
        debug: {
          msg: `If we're on zfs, maybe rename the docker storage?
`,
        },
      },
    ],
  },
] satisfies Playbook;
