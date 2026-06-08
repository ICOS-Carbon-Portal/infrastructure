import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";
import { nexus_home } from "../lib/sharedvars.ts";
import { tmpl } from "../lib/vars.ts";

export default playbook(import.meta, [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.nexus").tags("nexus"),
      role("icos.bbclient2", {
        bbclient_name: "nexus",
        bbclient_user: "root",
        bbclient_home: tmpl`${nexus_home}/bbclient`,
        bbclient_coldbackup: nexus_home,
      }).tags("bbclient"),
    ],
  },
]);
