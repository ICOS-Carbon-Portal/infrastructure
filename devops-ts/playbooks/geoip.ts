// Run everything
//   $ icos play geoip
//
// Deploy new version
//   $ icos play geoip geoip_app
//
// Show other tags
//   $ icos play geoip --list-tags
import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";

export default playbook(import.meta, [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.geoip"),
    ],
  },
]);
