import { isDefined, register, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const _slurp = register("_slurp");
const update = register("update");

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
        register: update,
        notify: "restart nebula",
      },
      {
        name: "Run validation",
        command: tmpl`nebula -test -config ${update.dest.ref}`,
        changed_when: false,
      },
    ],
    rescue: [
      {
        name: "Slurp failed file and add line numbers",
        command: tmpl`cat -n "${V.nebula_etc_dir}/config.yml"`,
        register: _slurp,
      },
      {
        name: "Restore config file",
        copy: {
          remote_src: true,
          dest: tmpl`${V.nebula_etc_dir}/config.yml`,
          src: update.backup_file.ref,
        },
        when: isDefined(update.backup_file),
      },
      {
        name: "Dump failed configuration",
        debug: { msg: _slurp.stdout.ref },
      },
      {
        name: "Fail",
        fail: { msg: "Nebula config file is broken" },
      },
    ],
    always: [
      {
        name: "Remove backup file",
        file: { name: update.backup_file.ref, state: "absent" },
        when: isDefined(update.backup_file),
      },
    ],
  },
] satisfies TaskFile;
