// Provision physical hosts with vmagent and node_exporter.
//
// upgrade to latest vmagent:
// icos play vmagent vmagent -evmagent_upgrade=1 -D
import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    hosts: "vmagent_hosts",
    roles: [
      role("icos.vmagent").tags("vmagent"),
      role("icos.node_exporter").tags("node"),
      role("icos.script_exporter", {
        sexp_exporters: ["smartmon"],
      }).tags("script"),
    ],
  },
] satisfies Playbook;
