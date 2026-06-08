// Provision physical hosts with vmagent and node_exporter.
//
// upgrade to latest vmagent:
// icos play vmagent vmagent -evmagent_upgrade=1 -D
import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";

export default playbook(import.meta, [
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
]);
