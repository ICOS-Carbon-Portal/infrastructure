import { caddy_bin } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "restart caddy",
    systemd: {
      name: "caddy",
      state: "restarted",
      daemon_reload: true,
    },
  },
  {
    name: "reload caddy",
    shell:
      tmpl`${caddy_bin} reload --config /etc/caddy/Caddyfile --adapter caddyfile`,
    changed_when: false,
  },
] satisfies TaskFile;
