import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";

// If we've been running xcaddy before this then we might have installed our
// overrides - see xcaddy.yml for details.
export default [
  {
    name: "Remove caddy dropin directory",
    file: {
      name: V.caddy_dropin_path.dirname(),
      state: "absent",
    },
    notify: "restart caddy",
  },
  {
    name: "Make /usr/bin/caddy executable",
    file: {
      path: "/usr/bin/caddy",
      mode: "+x",
    },
  },
] satisfies TaskFile;
