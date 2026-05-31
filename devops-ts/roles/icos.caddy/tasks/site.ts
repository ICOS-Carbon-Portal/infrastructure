import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  // FIXME: Remove in 2024
  {
    name: "Remove old caddy config files",
    file: {
      dest: V.item,
      state: "absent",
    },
    loop: [
      tmpl`/etc/caddy/sites/Caddyfile.${expr("caddy_name")}`,
      tmpl`/etc/caddy/${expr("caddy_name")}.caddy`,
    ],
  },
  {
    import_tasks: "config.yml",
    vars: {
      block: expr("caddy_conf"),
      marker: expr("caddy_name"),
      state: V.caddy_site_state,
      where: "EOF",
    },
  },
] satisfies TaskFile;
