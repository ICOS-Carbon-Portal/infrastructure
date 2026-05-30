import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  // FIXME: Remove in 2024
  {
    name: "Remove old caddy config files",
    file: {
      dest: V.item,
      state: "absent",
    },
    loop: [
      "/etc/caddy/sites/Caddyfile.{{ caddy_name }}",
      "/etc/caddy/{{ caddy_name }}.caddy",
    ],
  },
  {
    import_tasks: "config.yml",
    vars: {
      block: "{{ caddy_conf }}",
      marker: "{{ caddy_name }}",
      state: V.caddy_site_state,
      where: "EOF",
    },
  },
] satisfies TaskFile;
