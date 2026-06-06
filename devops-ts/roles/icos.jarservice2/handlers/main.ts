import { type TaskFile } from "../../../lib/ansible/play.ts";
import { jarservice_name, jarservice_state } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { eq, truthy } from "../../../lib/vars.ts";

export default [
  {
    name: tmpl`restart ${jarservice_name}`,
    service: {
      name: jarservice_name,
      state: "restarted",
    },
    when: eq(truthy(jarservice_state).default("started"), "started"),
  },
  {
    name: "reload systemd config",
    systemd: { daemon_reload: true },
  },
] satisfies TaskFile;
