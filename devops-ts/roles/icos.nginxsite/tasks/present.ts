import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create certificates",
    tags: "nginxsite_cert",
    include_role: {
      name: "icos.certbot2",
      apply: { tags: "nginxsite_cert" },
      public: true,
    },
    when: raw("nginxsite_domains is defined"),
  },
  {
    name: "Create basic auth users",
    tags: "nginxsite_users",
    include_role: {
      name: "icos.nginxauth",
      apply: { tags: "nginxsite_users" },
      public: true,
    },
    when: raw("nginxsite_users is defined"),
  },
  {
    block: [
      {
        name: "Copy config",
        template: {
          src: tmpl("{{ nginxsite_file }}"),
          dest: V.nginxsite_path_confd,
          backup: true,
        },
        register: "update",
      },
      {
        name: "Remove old config file from sites-available",
        file: {
          dest: V.nginxsite_path_available,
          state: "absent",
        },
      },
      {
        name: "Remove old symlink sites-enabled",
        file: {
          dest: V.nginxsite_path_enable,
          state: "absent",
        },
      },
      {
        name: "Check syntax",
        // noqa: command-instead-of-shell
        shell: "nginx -t",
        changed_when: false,
      },
      {
        name: "Reload nginx",
        systemd: {
          name: "nginx",
          state: "reloaded",
        },
        changed_when: false,
      },
    ],
    rescue: [
      {
        name: "Restore old config",
        copy: {
          remote_src: true,
          dest: tmpl("{{ update.dest }}"),
          src: tmpl("{{ update.backup_file }}"),
        },
        when: raw("update.backup_file is defined"),
      },
      {
        name: "Remove broken config",
        file: {
          path: tmpl("{{ update.dest }}"),
          state: "absent",
        },
        when: raw("update.backup_file is not defined"),
      },
    ],
    always: [
      {
        name: "Remove backup file",
        file: {
          path: tmpl("{{ update.backup_file }}"),
          state: "absent",
        },
        changed_when: false,
        when: raw("update.backup_file is defined"),
      },
    ],
  },
] satisfies TaskFile;
