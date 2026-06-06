import { dnsmasq_config_state } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { eq } from "../../../lib/vars.ts";

export default [
  {
    import_tasks: "config_present.yml",
    when: eq(dnsmasq_config_state, "present"),
  },
  {
    import_tasks: "config_absent.yml",
    when: eq(dnsmasq_config_state, "absent"),
  },
] satisfies TaskFile;
