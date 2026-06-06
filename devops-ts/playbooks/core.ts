import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";
import {
  cpauth_domains,
  cpauth_envries,
  doi_certbot_name,
  virtuoso_enable,
} from "../lib/globals.ts";
import { isDefined, jre_apt_package } from "../lib/vars.ts";

export default [
  {
    hosts: "core_server",
    tasks: [
      {
        name: "Setup cpmeta proxy",
        tags: ["proxy", "cpmeta_proxy"],
        import_role: { name: "icos.cpmeta", tasks_from: "proxy.yml" },
      },
      {
        name: "Setup cpdata proxy",
        tags: ["proxy", "cpdata_proxy"],
        import_role: { name: "icos.cpdata", tasks_from: "proxy.yml" },
      },
      {
        name: "Setup cpauth proxy",
        tags: ["proxy", "cpauth_proxy"],
        import_role: { name: "icos.cpauth", tasks_from: "proxy.yml" },
        when: isDefined(cpauth_domains),
      },
      {
        name: "Setup restheart proxy",
        tags: ["proxy", "restheart_proxy"],
        import_role: { name: "icos.restheart", tasks_from: "proxy.yml" },
      },
      {
        name: "Setup doi proxy",
        tags: ["proxy", "doi_proxy"],
        import_role: { name: "icos.doi", tasks_from: "proxy.yml" },
        when: isDefined(doi_certbot_name),
      },
    ],
  },
  {
    hosts: "core_host",
    // Global vars shared by all deployment targets; declared in the hand-curated
    // `Vars` registry (lib/vars.ts) and referenced via the explicit global `V`.
    vars: {
      jre_apt_package: "openjdk-21-jre-headless",
      java_path: "/usr/lib/jvm/java-21-openjdk-amd64/bin/java",
    },
    pre_tasks: [
      {
        name: "Install jre",
        apt: { name: jre_apt_package },
      },
      {
        name: "Setup rdflog",
        tags: "rdflog",
        import_role: { name: "icos.rdflog", tasks_from: "setup.yml" },
      },
      {
        name: "Setup rdflog backup",
        tags: "rdflog_backup",
        import_role: { name: "icos.rdflog", tasks_from: "backup.yml" },
      },
    ],
    roles: [
      role("icos.postgis").tags("postgis"),
      role("icos.restheart"),
      role("icos.cpmeta"),
      role("icos.cpdata"),
      role("icos.cpauth").when(isDefined(cpauth_envries)),
      role("icos.doi"),
      role("icos.virtuoso").tags("virtuoso").when(
        isDefined(virtuoso_enable).default(false),
      ),
    ],
  },
] satisfies Playbook;

// After this playbook has ran, deploy the jar-files of cpmeta, cpdata and (if
// needed) cpauth and doi using sbt
