import { expr, type Playbook, tmpl } from "../../lib/ansible.ts";

export default [
  {
    hosts: "cdb",
    vars: {
      old_name: "pgrep-rdflog",
      new_name: "pgrep2",
      ssh_port: expr("hostvars[new_name].ansible_port"),
    },
    tasks: [
      {
        name: "stop container",
        command: tmpl`lxc stop ${expr("old_name")}`,
        register: "r",
        failed_when: ["r.rc != 0", "'not found' not in r.stderr.lower()"],
        changed_when: ["r.rc == 0"],
      },
      {
        name: "rename container",
        command: tmpl`lxc rename ${expr("old_name")} ${expr("new_name")}`,
        register: "r",
        failed_when: ["r.rc != 0", "'not found' not in r.stderr.lower()"],
        changed_when: ["r.rc == 0"],
      },
      {
        name: "Modify /etc/hosts",
        lineinfile: {
          path: "/etc/hosts",
          regex: tmpl`(\\S*)\\s+(?:${expr("old_name")})\\.lxd$`,
          line: tmpl`\\1\\t${expr("new_name")}.lxd`,
          state: "present",
          backrefs: true,
        },
        register: "r",
      },
      {
        name: "Remove old iptables rule",
        iptables_raw: {
          name: tmpl`forward_ssh_to_${expr("old_name")}`,
          state: "absent",
          table: "nat",
        },
      },
      {
        name: "Get ip of host",
        shell: tmpl`awk '/${expr("new_name")}/ {print $1}' < /etc/hosts`,
        changed_when: false,
        register: "ip",
      },
      {
        name: "Add new forwarding rule",
        iptables_raw: {
          name: tmpl`forward_ssh_to_${expr("new_name")}`,
          table: "nat",
          rules: tmpl`-A PREROUTING -p tcp --dport ${
            expr("ssh_port")
          } -j DNAT --to-destination ${expr("ip.stdout")}:22`,
        },
      },
      {
        name: "start container",
        command: tmpl`lxc start ${expr("new_name")}`,
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
