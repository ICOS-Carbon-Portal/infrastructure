import {
  dnsmasq_config_dir,
  dnsmasq_config_file,
  dnsmasq_service_name,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { dnsmasq_config } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { iff, tmpl } from "../../../lib/template.ts";
import { isDefined } from "../../../lib/vars.ts";

const _slurp = register("_slurp");

const config = register("config");

const check = register("check");

export default [
  {
    block: [
      {
        name: "Copy dnsmasq config",
        copy: {
          content: dnsmasq_config,
          dest: dnsmasq_config_file,
          backup: true,
        },
        register: config,
      },
      {
        name: "Run validation",
        command: tmpl`dnsmasq --test --conf-dir ${dnsmasq_config_dir}`,
        changed_when: config.changed,
        register: check,
      },
    ],
    rescue: [
      {
        name: "Slurp failed file and add line numbers",
        command: tmpl`cat -n ${dnsmasq_config}`,
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
          dest: dnsmasq_config,
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
      name: dnsmasq_service_name,
      enabled: true,
      state: iff(check.changed, "restarted", "started"),
    },
  },
] satisfies TaskFile;
