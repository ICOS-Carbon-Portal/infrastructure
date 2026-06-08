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
import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";
import { cpauth_domains } from "../lib/globals.ts";
import { cpauth_cert_name } from "../lib/vars.ts";

export default playbook(import.meta, [
  {
    hosts: "fsicos2",
    roles: [
      role("icos.certbot2", {
        certbot_name: cpauth_cert_name,
        certbot_domains: cpauth_domains,
      }).tags("cert"),

      role("icos.cpauth").tags("cpauth"),
    ],
    tasks: [
      {
        name: "Install cpauth backup",
        tags: "backup",
        import_role: { name: "icos.cpauth", tasks_from: "backup" },
      },
    ],
  },
]);
