import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  // FIXME: Remove in 2024
  {
    name: "Remove old caddy config files",
    file: {
      dest: V.item,
      state: "absent",
    },
    loop: [
      tmpl`/etc/caddy/sites/Caddyfile.${V.caddy_name}`,
      tmpl`/etc/caddy/${V.caddy_name}.caddy`,
    ],
  },
  {
    import_tasks: "config.yml",
    vars: {
      block: V.caddy_conf,
      marker: V.caddy_name,
      state: V.caddy_site_state,
      where: "EOF",
    },
  },
] satisfies TaskFile;
