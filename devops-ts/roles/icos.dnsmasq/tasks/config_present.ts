import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    block: [
      {
        name: "Copy dnsmasq config",
        copy: {
          content: "{{ dnsmasq_config }}",
          dest: V.dnsmasq_config_file,
          backup: true,
        },
        register: "config",
      },
      {
        name: "Run validation",
        command: tmpl`dnsmasq --test --conf-dir ${V.dnsmasq_config_dir}`,
        changed_when: "config.changed",
        register: "check",
      },
    ],
    rescue: [
      {
        name: "Slurp failed file and add line numbers",
        command: "cat -n {{ dnsmasq_config }}",
        register: "_slurp",
      },
      {
        name: "Dump failed configuration",
        debug: {
          msg: "{{ _slurp.stdout }}",
        },
      },
      {
        name: "Restore config file",
        copy: {
          remote_src: true,
          dest: "{{ dnsmasq_config }}",
          src: "{{ config.backup_file }}",
        },
      },
    ],
    always: [
      {
        name: "Remove backup file",
        file: {
          name: "{{ config.backup_file }}",
          state: "absent",
        },
        when: raw("config['backup_file'] is defined"),
      },
    ],
  },
  {
    name: "Restart dnsmasq",
    systemd: {
      name: V.dnsmasq_service_name,
      enabled: true,
      state: "{{ 'restarted' if check.changed else 'started' }}",
    },
  },
] satisfies TaskFile;
