// This playbook contains various domains.
import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";

export default playbook(import.meta, [
  {
    hosts: "fsicos2",
    roles: [
      // ICOS RI
      role("icos.certbot2", {
        certbot_name: "icos-ri.eu",
        certbot_domains: [
          "icos-ri.eu",
          "www.icos-ri.eu",
          "conference.icos-ri.eu",
        ],
      }).tags("icos-ri"),

      role("icos.nginxsite", {
        nginxsite_name: "icos-ri",
        nginxsite_file: "files/domains/icos-ri.conf",
      }).tags("icos-ri"),

      // ICOS CITIES
      role("icos.certbot2", {
        certbot_name: "icos-cities",
        certbot_domains: [
          "paul.icos-cp.eu",
          "paul.icos-ri.eu",
          "icos-cities.eu",
          "www.icos-cities.eu",
        ],
      }).tags("icos-cities"),

      role("icos.nginxsite", {
        vars: {
          nginxsite_name: "icos-cities",
          nginxsite_file: "files/domains/icos-cities.conf",
        },
      }).tags("icos-cities"),
    ],
  },
]);
