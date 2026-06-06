import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

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
      tmpl`${V.caddy_bin} reload --config /etc/caddy/Caddyfile --adapter caddyfile`,
    changed_when: false,
  },
] satisfies TaskFile;
