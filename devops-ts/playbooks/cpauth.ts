// Stepwise deployment of cpauth:
//
// Generate certbot certificates
//   $ icos play cpauth cert
//
// Create user and install nginx config
//   $ icos play cpauth cpauth_setup
//
// Full redeploy
//   $ icos play cpauth cpauth -ecpauth_jar_file=/tmp/cpauth.jar
//
// Deploy bbclient and cpauth's backup script
//   $ icos play cpauth bbclient cpauth_backup
import { type Playbook, role, V } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.certbot2", {
        certbot_name: V.cpauth_cert_name,
        certbot_domains: V.cpauth_domains,
      }).opt({ tags: "cert" }),

      role("icos.cpauth").opt({ tags: "cpauth" }),
    ],
    tasks: [
      {
        name: "Install cpauth backup",
        tags: "backup",
        import_role: { name: "icos.cpauth", tasks_from: "backup" },
      },
    ],
  },
] satisfies Playbook;
