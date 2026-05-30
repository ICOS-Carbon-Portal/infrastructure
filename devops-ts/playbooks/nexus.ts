import { type Playbook, role, tmpl, V } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.nexus").tags("nexus"),
      role("icos.bbclient2", {
        bbclient_name: "nexus",
        bbclient_user: "root",
        bbclient_home: tmpl`${V.nexus_home}/bbclient`,
        bbclient_coldbackup: V.nexus_home,
      }).tags("bbclient"),
    ],
  },
] satisfies Playbook;
