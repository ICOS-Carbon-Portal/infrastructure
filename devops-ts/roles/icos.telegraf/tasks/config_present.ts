import { raw, register, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const _slurp = register("_slurp");

const update = register("update");

export default [
  {
    block: [
      {
        name: "Create telegraf config file",
        copy: {
          dest: tmpl`${V.telegraf_config_root}/${V.telegraf_config_file}`,
          content: V.telegraf_config,
          backup: true,
        },
        register: update,
      },
      {
        name: "Run validation",
        // redirect stdout to /dev/null since it will contain the metrics (which
        // can be a lot of lines); stderr will contain the messages.
        shell: tmpl`telegraf --test --config ${update.dest.ref} > /dev/null`,
        register: "test",
        changed_when: update.changed,
        failed_when: [
          "test.failed",
          // If we run test on a config file containing agent-only config, it'll
          // fail because it has no inputs!
          "test.stderr.find('no inputs found') < 0",
        ],
        notify: "reload telegraf",
      },
    ],
    rescue: [
      {
        name: "Slurp failed file and add line numbers",
        command: tmpl`cat -n ${update.dest.ref}`,
        changed_when: false,
        register: _slurp,
      },
      {
        name: "Restore config file",
        copy: {
          remote_src: true,
          dest: update.dest.ref,
          src: update.backup_file.ref,
        },
      },
      {
        name: "Dump failed configuration",
        debug: { msg: _slurp.stdout.ref },
      },
      {
        name: "Fail",
        fail: { msg: "Telegraf config file is broken" },
      },
    ],
    always: [
      {
        name: "Remove backup file",
        file: { name: update.backup_file.ref, state: "absent" },
        when: raw("update['backup_file'] is defined"),
      },
    ],
  },
  {
    name: "Make sure telegraf is started",
    systemd: { name: "telegraf", enabled: true, state: "started" },
  },
] satisfies TaskFile;
