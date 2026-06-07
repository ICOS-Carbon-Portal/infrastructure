import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { caddy_conf, caddy_name } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  // FIXME: Remove in 2024
  {
    name: "Remove old caddy config files",
    file: {
      dest: item,
      state: "absent",
    },
    loop: [
      tmpl`/etc/caddy/sites/Caddyfile.${caddy_name}`,
      tmpl`/etc/caddy/${caddy_name}.caddy`,
    ],
  },
  {
    import_tasks: "config.yml",
    vars: {
      block: caddy_conf,
      marker: caddy_name,
      state: V.caddy_site_state,
      where: "EOF",
    },
  },
] satisfies TaskFile;
