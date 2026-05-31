import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    block: [
      {
        name: "Copy nebula_config.yml",
        template: {
          src: V.nebula_config_file,
          dest: tmpl`${V.nebula_etc_dir}/config.yml`,
          lstrip_blocks: true,
          backup: true,
        },
        register: "update",
        notify: "restart nebula",
      },
      {
        name: "Run validation",
        command: tmpl`nebula -test -config ${expr("update.dest")}`,
        changed_when: false,
      },
    ],
    rescue: [
      {
        name: "Slurp failed file and add line numbers",
        command: tmpl`cat -n "${V.nebula_etc_dir}/config.yml"`,
        register: "_slurp",
      },
      {
        name: "Restore config file",
        copy: {
          remote_src: true,
          dest: tmpl`${V.nebula_etc_dir}/config.yml`,
          src: expr("update.backup_file"),
        },
        when: raw("update['backup_file'] is defined"),
      },
      {
        name: "Dump failed configuration",
        debug: { msg: expr("_slurp.stdout") },
      },
      {
        name: "Fail",
        fail: { msg: "Nebula config file is broken" },
      },
    ],
    always: [
      {
        name: "Remove backup file",
        file: { name: expr("update.backup_file"), state: "absent" },
        when: raw("update['backup_file'] is defined"),
      },
    ],
  },
] satisfies TaskFile;
