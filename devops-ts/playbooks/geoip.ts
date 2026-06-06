// Run everything
//   $ icos play geoip
//
// Deploy new version
//   $ icos play geoip geoip_app
//
// Show other tags
//   $ icos play geoip --list-tags
import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";

export default [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.geoip"),
    ],
  },
] satisfies Playbook;
