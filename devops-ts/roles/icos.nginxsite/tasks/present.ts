import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import {
  nginxsite_domains,
  nginxsite_file,
  nginxsite_users,
} from "../../../lib/sharedvars.ts";
import { isDefined, isNotDefined } from "../../../lib/vars.ts";

const update = register("update");

export default [
  {
    name: "Create certificates",
    tags: "nginxsite_cert",
    include_role: {
      name: "icos.certbot2",
      apply: { tags: "nginxsite_cert" },
      public: true,
    },
    when: isDefined(nginxsite_domains),
  },
  {
    name: "Create basic auth users",
    tags: "nginxsite_users",
    include_role: {
      name: "icos.nginxauth",
      apply: { tags: "nginxsite_users" },
      public: true,
    },
    when: isDefined(nginxsite_users),
  },
  {
    block: [
      {
        name: "Copy config",
        template: {
          src: nginxsite_file,
          dest: V.nginxsite_path_confd,
          backup: true,
        },
        register: update,
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
          dest: update.dest.ref,
          src: update.backup_file.ref,
        },
        when: isDefined(update.backup_file),
      },
      {
        name: "Remove broken config",
        file: {
          path: update.dest.ref,
          state: "absent",
        },
        when: isNotDefined(update.backup_file),
      },
    ],
    always: [
      {
        name: "Remove backup file",
        file: {
          path: update.backup_file.ref,
          state: "absent",
        },
        changed_when: false,
        when: isDefined(update.backup_file),
      },
    ],
  },
] satisfies TaskFile;
