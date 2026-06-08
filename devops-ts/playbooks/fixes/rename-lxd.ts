import { playbook } from "../../lib/ansible/playbook.ts";
import { new_name, old_name, ssh_port } from "../../lib/paramvars.ts";
import { register } from "../../lib/register.ts";
import { eq, hostvar, ne, notIn, tmpl } from "../../lib/vars.ts";

const ip = register("ip");
const r = register("r");

export default playbook(import.meta, [
  {
    hosts: "cdb",
    vars: {
      old_name: "pgrep-rdflog",
      new_name: "pgrep2",
      ssh_port: hostvar(new_name).ansible_port,
    },
    tasks: [
      {
        name: "stop container",
        command: tmpl`lxc stop ${old_name}`,
        register: r,
        failed_when: [ne(r.rc, 0), notIn("not found", r.stderr.lower())],
        changed_when: [eq(r.rc, 0)],
      },
      {
        name: "rename container",
        command: tmpl`lxc rename ${old_name} ${new_name}`,
        register: r,
        failed_when: [ne(r.rc, 0), notIn("not found", r.stderr.lower())],
        changed_when: [eq(r.rc, 0)],
      },
      {
        name: "Modify /etc/hosts",
        lineinfile: {
          path: "/etc/hosts",
          regex: tmpl`(\\S*)\\s+(?:${old_name})\\.lxd$`,
          line: tmpl`\\1\\t${new_name}.lxd`,
          state: "present",
          backrefs: true,
        },
        register: r,
      },
      {
        name: "Remove old iptables rule",
        iptables_raw: {
          name: tmpl`forward_ssh_to_${old_name}`,
          state: "absent",
          table: "nat",
        },
      },
      {
        name: "Get ip of host",
        shell: tmpl`awk '/${new_name}/ {print $1}' < /etc/hosts`,
        changed_when: false,
        register: ip,
      },
      {
        name: "Add new forwarding rule",
        iptables_raw: {
          name: tmpl`forward_ssh_to_${new_name}`,
          table: "nat",
          rules:
            tmpl`-A PREROUTING -p tcp --dport ${ssh_port} -j DNAT --to-destination ${ip.stdout.ref}:22`,
        },
      },
      {
        name: "start container",
        command: tmpl`lxc start ${new_name}`,
      },
      {
        debug: {
          msg: `If we're on zfs, maybe rename the docker storage?
`,
        },
      },
    ],
  },
]);
