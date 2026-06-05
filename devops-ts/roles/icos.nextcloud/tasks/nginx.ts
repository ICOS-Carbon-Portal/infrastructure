import {
  isDefined,
  register,
  type TaskFile,
  truthy,
} from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

const _slurp = register("_slurp");

const update = register("update");

export default [
  {
    import_role: { name: "icos.certbot2" },
    when: truthy(V.nextcloud_certbot_enable),
  },
  {
    block: [
      {
        name: "Copy nextcloud-nginx.conf",
        template: {
          src: "nextcloud-nginx.conf",
          dest: "/etc/nginx/conf.d/nextcloud.conf",
          lstrip_blocks: true,
          backup: true,
        },
        register: update,
      },
      {
        name: "Run validation",
        command: "nginx -t",
        changed_when: update.changed,
        notify: "reload nginx config",
      },
    ],
    rescue: [
      {
        name: "Slurp failed file and add line numbers",
        command: "cat -n /etc/nginx/conf.d/nextcloud.conf",
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
          dest: "/etc/nginx/conf.d/nextcloud.conf",
          src: update.backup_file.ref,
        },
        when: isDefined(update.backup_file),
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
      {
        name: "Flush handlers",
        meta: "flush_handlers",
      },
    ],
  },
] satisfies TaskFile;
