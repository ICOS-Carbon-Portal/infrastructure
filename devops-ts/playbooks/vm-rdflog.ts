import { type Playbook, role, tmpl } from "../lib/ansible.ts";

// Deploy the postgres replication containers
//   icos play rdflog pgrep

// RDFLOG
export default [
  {
    hosts: "rdflog_server",
    tags: "rdflog",
    roles: [
      role("icos.rdflog"),
    ],
  },
  // CREATE VMS
  {
    hosts: "pgrep_rdflog_server",
    tags: "vm",
    roles: [
      role("icos.lxd_vm", {
        lxd_vm_name: tmpl("{{ rdflog_vm_name }}"),
        lxd_vm_docker: true,
      }),
    ],
  },
  // REPLICAS
  {
    hosts: "pgrep_rdflog",
    tags: "replica",
    roles: [
      role("icos.lxd_guest").tags("guest"),

      role("icos.docker").tags("docker"),

      role("icos.pgrep").tags("pgrep"),
    ],
  },
] satisfies Playbook;
