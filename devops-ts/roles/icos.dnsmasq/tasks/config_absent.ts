import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { eq } from "../../../lib/vars.ts";

export default [
  {
    name: "Fail if user is trying to remove main config file",
    fail: {
      msg: "We're not setup to remove the default config file.",
    },
    // Source uses a single-element YAML list for `when:`; preserved as an array.
    when: [eq(V.dnsmasq_config_name, "config")],
  },
  {
    name: "Remove dnsmasq config file",
    file: {
      name: V.dnsmasq_config_file,
      state: "absent",
    },
    notify: "dnsmasq restart",
  },
] satisfies TaskFile;
