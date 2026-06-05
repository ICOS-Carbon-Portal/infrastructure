import {
  iff,
  isDefined,
  register,
  type TaskFile,
} from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const _slurp = register("_slurp");

const config = register("config");

const check = register("check");

export default [
  {
    block: [
      {
        name: "Copy dnsmasq config",
        copy: {
          content: V.dnsmasq_config,
          dest: V.dnsmasq_config_file,
          backup: true,
        },
        register: config,
      },
      {
        name: "Run validation",
        command: tmpl`dnsmasq --test --conf-dir ${V.dnsmasq_config_dir}`,
        changed_when: config.changed,
        register: check,
      },
    ],
    rescue: [
      {
        name: "Slurp failed file and add line numbers",
        command: tmpl`cat -n ${V.dnsmasq_config}`,
        register: _slurp,
      },
      {
        name: "Dump failed configuration",
        debug: {
          msg: _slurp.stdout.ref,
        },
      },
      {
        name: "Restore config file",
        copy: {
          remote_src: true,
          dest: V.dnsmasq_config,
          src: config.backup_file.ref,
        },
      },
    ],
    always: [
      {
        name: "Remove backup file",
        file: {
          name: config.backup_file.ref,
          state: "absent",
        },
        when: isDefined(config.backup_file),
      },
    ],
  },
  {
    name: "Restart dnsmasq",
    systemd: {
      name: V.dnsmasq_service_name,
      enabled: true,
      state: iff(check.changed, "restarted", "started"),
    },
  },
] satisfies TaskFile;
