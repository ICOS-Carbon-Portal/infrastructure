// Build mailman images
//   icos play mailman mailman_build
//
// Copy build files but do not build nor start containers.
//   icos play mailman mailman_build -edocker_do_build=False
//
// Redeploy backup scripts
//   icos play mailman bbclient
//
// Redeploy proxy configuration
//   icos play mailman proxy

import { expr, type Playbook, role, tmpl, V } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos2",
    vars: {
      mailman_rest_pass: expr("vault_mailman_rest_pass"),
      mailman_rest_allow_deny: expr("vault_mailman_rest_allow_deny"),
      mailman_domains: [
        "lists.icos-ri.eu",
        "lists.eric-forum.eu",
        "lists.icos-cities.eu",
        "lists.kadi-project.eu",
      ],
    },
    roles: [
      role("icos.mailman").tags("mailman"),

      role("icos.bbclient2", {
        vars: {
          bbclient_name: "mailman",
          bbclient_user: "root",
          bbclient_home: tmpl`${V.mailman_home}/bbclient`,
          bbclient_coldbackup: V.mailman_home,
          bbclient_remotes: [
            "fsicos2",
            "icos1",
          ],
        },
      }).tags("bbclient"),
    ],
    tasks: [
      {
        name: "Install proxy for mailman",
        tags: "proxy",
        import_role: {
          name: "icos.mailman",
          tasks_from: "proxy",
        },
      },
    ],
  },
] satisfies Playbook;
