import { isDefined, type Playbook, role, scopeVars } from "../lib/ansible.ts";

// Global vars shared by all deployment targets on core_host; defined here to
// avoid repeating them in the inventories.
const core = scopeVars({
  jre_apt_package: "openjdk-21-jre-headless",
  java_path: "/usr/lib/jvm/java-21-openjdk-amd64/bin/java",
});

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
        when: isDefined("cpauth_domains"),
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
        when: isDefined("doi_certbot_name"),
      },
    ],
  },
  {
    hosts: "core_host",
    vars: core.vars,
    pre_tasks: [
      {
        name: "Install jre",
        apt: { name: core.ref.jre_apt_package },
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
      role("icos.cpauth").when(isDefined("cpauth_envries")),
      role("icos.doi"),
      role("icos.virtuoso").tags("virtuoso").when(
        isDefined("virtuoso_enable").default(false),
      ),
    ],
  },
] satisfies Playbook;

// After this playbook has ran, deploy the jar-files of cpmeta, cpdata and (if
// needed) cpauth and doi using sbt
