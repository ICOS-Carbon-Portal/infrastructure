import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.nexus").opt({ tags: "nexus" }),
      role("icos.bbclient2", {
        bbclient_name: "nexus",
        bbclient_user: "root",
        bbclient_home: "{{ nexus_home }}/bbclient",
        bbclient_coldbackup: "{{ nexus_home }}",
      }).opt({ tags: "bbclient" }),
    ],
  },
] satisfies Playbook;
