// Run everything
//   $ icos play geoip
//
// Deploy new version
//   $ icos play geoip geoip_app
//
// Show other tags
//   $ icos play geoip --list-tags
import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.geoip"),
    ],
  },
] satisfies Playbook;
