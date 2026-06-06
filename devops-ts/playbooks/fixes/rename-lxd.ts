import { type Playbook } from "../../lib/ansible/play.ts";
import { register } from "../../lib/register.ts";
import { eq, hostvar, ne, notIn, tmpl, V } from "../../lib/vars.ts";

const ip = register("ip");
const r = register("r");

export default [
  {
    hosts: "cdb",
    vars: {
      old_name: "pgrep-rdflog",
      new_name: "pgrep2",
      ssh_port: hostvar(V.new_name).ansible_port,
    },
    tasks: [
      {
        name: "stop container",
        command: tmpl`lxc stop ${V.old_name}`,
        register: r,
        failed_when: [ne(r.rc, 0), notIn("not found", r.stderr.lower())],
        changed_when: [eq(r.rc, 0)],
      },
      {
        name: "rename container",
        command: tmpl`lxc rename ${V.old_name} ${V.new_name}`,
        register: r,
        failed_when: [ne(r.rc, 0), notIn("not found", r.stderr.lower())],
        changed_when: [eq(r.rc, 0)],
      },
      {
        name: "Modify /etc/hosts",
        lineinfile: {
          path: "/etc/hosts",
          regex: tmpl`(\\S*)\\s+(?:${V.old_name})\\.lxd$`,
          line: tmpl`\\1\\t${V.new_name}.lxd`,
          state: "present",
          backrefs: true,
        },
        register: r,
      },
      {
        name: "Remove old iptables rule",
        iptables_raw: {
          name: tmpl`forward_ssh_to_${V.old_name}`,
          state: "absent",
          table: "nat",
        },
      },
      {
        name: "Get ip of host",
        shell: tmpl`awk '/${V.new_name}/ {print $1}' < /etc/hosts`,
        changed_when: false,
        register: ip,
      },
      {
        name: "Add new forwarding rule",
        iptables_raw: {
          name: tmpl`forward_ssh_to_${V.new_name}`,
          table: "nat",
          rules:
            tmpl`-A PREROUTING -p tcp --dport ${V.ssh_port} -j DNAT --to-destination ${ip.stdout.ref}:22`,
        },
      },
      {
        name: "start container",
        command: tmpl`lxc start ${V.new_name}`,
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
