import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { isDefined } from "../../../lib/vars.ts";
import { V } from "../_ctx.ts";

const _slurp = register("_slurp");

const update = register("update");

export default [
  {
    block: [
      {
        name: "Create zrepl.yaml",
        copy: {
          content: V.zrepl_config,
          dest: "/etc/zrepl/zrepl.yml",
          backup: true,
        },
        register: update,
      },
      {
        name: "Run validation",
        command: "zrepl configcheck",
        changed_when: update.changed,
        notify: "restart zrepl",
      },
    ],
    rescue: [
      {
        name: "Slurp failed file and add line numbers",
        command: "cat -n /etc/zrepl/zrepl.yml",
        register: _slurp,
      },
      {
        name: "Restore config file",
        copy: {
          remote_src: true,
          dest: "/etc/zrepl/zrepl.yml",
          src: update.backup_file.ref,
        },
      },
      {
        name: "Dump failed configuration",
        debug: { msg: _slurp.stdout.ref },
      },
      {
        name: "Validation failed",
        fail: { msg: "Error in config.yaml" },
      },
    ],
    always: [
      {
        name: "Remove backup file",
        file: {
          name: update.backup_file.ref,
          state: "absent",
        },
        when: isDefined(update.backup_file),
      },
    ],
  },
] satisfies TaskFile;
