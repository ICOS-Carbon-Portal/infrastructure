import { raw, register, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

const _slurp = register("_slurp");

const _r = register("_r");

// If caddy config validation fails, it's useful to see the full (failed)
// config file with line numbers. But since the blockinfile module remove the
// temporary file immediately if using the 'validate' key, we have to resort to
// this elaborate dance.
export default [
  {
    block: [
      {
        name: "Add caddy configuration block",
        blockinfile: {
          path: "/etc/caddy/Caddyfile",
          block: V.block,
          marker: tmpl`# {mark} ${V.marker}`,
          state: V.state.default(V.omit),
          backup: true,
          create: true,
          insertafter: expr("'EOF' if where == 'EOF' else omit"),
          insertbefore: expr("'BOF' if where == 'BOF' else omit"),
        },
        register: _r,
      },
      {
        name: "Run validation",
        command: tmpl`${V.caddy_bin} validate`,
        args: { chdir: "/etc/caddy" },
        changed_when: _r.changed,
        notify: "reload caddy",
      },
    ],
    rescue: [
      {
        name: "Slurp failed file and add line numbers",
        command: "cat -n /etc/caddy/Caddyfile",
        register: _slurp,
      },
      {
        name: "Dump failed configuration",
        debug: { msg: _slurp.stdout.ref },
      },
      {
        name: "Restore config file",
        copy: {
          remote_src: true,
          dest: "/etc/caddy/Caddyfile",
          src: _r.backup_file.ref,
        },
        // backup_file won't be set if templating failed
        when: raw("_r['backup_file'] is defined"),
      },
    ],
    always: [
      {
        name: "Remove backup file",
        file: {
          name: _r.backup_file.ref,
          state: "absent",
        },
        changed_when: false,
        when: raw("_r['backup_file'] is defined"),
      },
    ],
  },
] satisfies TaskFile;
