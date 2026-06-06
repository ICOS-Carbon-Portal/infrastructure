import { caddy_bin } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { omit } from "../../../lib/builtins.ts";
import { block, marker, state, where } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { iff, tmpl } from "../../../lib/template.ts";
import { eq, isDefined } from "../../../lib/vars.ts";

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
          block: block,
          marker: tmpl`# {mark} ${marker}`,
          state: state.default(omit),
          backup: true,
          create: true,
          insertafter: iff(eq(where, "EOF"), "EOF", omit),
          insertbefore: iff(eq(where, "BOF"), "BOF", omit),
        },
        register: _r,
      },
      {
        name: "Run validation",
        command: tmpl`${caddy_bin} validate`,
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
        when: isDefined(_r.backup_file),
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
        when: isDefined(_r.backup_file),
      },
    ],
  },
] satisfies TaskFile;
