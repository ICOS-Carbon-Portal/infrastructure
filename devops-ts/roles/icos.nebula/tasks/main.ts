import { nebula_resolve_enable } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { nebula_ssh_enable } from "../../../lib/globals.ts";
import { nebula_ssh_public } from "../../../lib/paramvars.ts";
import { isNotDefined, truthy } from "../../../lib/vars.ts";

export default [
  { import_tasks: "install.yml", tags: "nebula_install" },
  {
    when: [
      truthy(nebula_ssh_enable),
      isNotDefined(nebula_ssh_public),
    ],
    import_tasks: "ssh.yml",
    tags: ["nebula_ssh", "nebula_config"],
  },
  { import_tasks: "just.yml", tags: "nebula_just" },
  { import_tasks: "ca.yml", tags: "nebula_ca" },
  { import_tasks: "cert.yml", tags: "nebula_cert" },
  { import_tasks: "iptables.yml", tags: "nebula_iptables" },
  { import_tasks: "config.yml", tags: "nebula_config" },
  { import_tasks: "service.yml", tags: "nebula_service" },
  { import_tasks: "hosts.yml", tags: "nebula_hosts" },
  {
    when: truthy(nebula_resolve_enable),
    import_tasks: "resolve.yml",
    tags: "nebula_resolve",
  },
  {
    import_tasks: "test.yml",
    tags: [
      "nebula_test",
      // always run tests when reconfiguring resolve
      "nebula_resolve",
    ],
  },
] satisfies TaskFile;
