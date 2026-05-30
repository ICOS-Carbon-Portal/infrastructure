import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos4",
    roles: [
      role("icos.caddy", {
        caddy_name: "fdpdemo",
        // Literal block — the template content is dedented to column 0 so it
        // matches the original `|` block byte-for-byte (incl. trailing newline).
        caddy_conf: `fdpdemo.envri.eu {
    reverse_proxy 10.10.10.236:80
}
`,
      }).tags("caddy"),
    ],
  },
  {
    hosts: "fdp",
    roles: [
      role("icos.fairdatapoint").tags("fairdatapoint"),
    ],
  },
] satisfies Playbook;
