import { raw, register, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

const update = register("update");

export default [
  {
    block: [
      {
        name: "Create zrepl.yaml",
        copy: {
          content: expr("zrepl_config"),
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
        register: "_slurp",
      },
      {
        name: "Restore config file",
        copy: {
          remote_src: true,
          dest: "/etc/zrepl/zrepl.yml",
          src: expr("update.backup_file"),
        },
      },
      {
        name: "Dump failed configuration",
        debug: { msg: expr("_slurp.stdout") },
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
          name: expr("_r.backup_file"),
          state: "absent",
        },
        when: raw("_r['backup_file'] is defined"),
      },
    ],
  },
] satisfies TaskFile;
