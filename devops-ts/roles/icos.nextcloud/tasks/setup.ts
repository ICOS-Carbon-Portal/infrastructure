import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create nextcloud docker directory",
    file: {
      path: V.nextcloud_home,
      state: "directory",
      mode: "og-rw",
    },
  },
  {
    include_role: { name: "icos.password_env_file" },
    vars: {
      file: "{{ item.file }}",
      set_fact: "{{ item.set_fact }}",
      file_var: "{{ item.file_var }}",
    },
    loop: [
      {
        file: tmpl`${V.nextcloud_home}/.pg-root-pass`,
        set_fact: "nextcloud_db_root_pass",
        file_var: "POSTGRES_PASSWORD",
      },
      {
        file: tmpl`${V.nextcloud_home}/.pg-nextcloud-pass`,
        set_fact: "nextcloud_db_pass",
        file_var: "NEXTCLOUD_PASSWORD",
      },
    ],
  },
  {
    name: "Copy files",
    template: {
      src: V.item,
      dest: V.nextcloud_home,
    },
    loop: [
      "nextcloud.env",
      "postgres.env",
      "tweak.conf",
      "init.sql",
      "docker-compose.yml",
    ],
  },
  // Note that we do not start nextcloud automatically. Since we only have a
  // single installation, and since it's a behemoth, it doesn't make
  // sense. Bringing nextcloud up and down is done manually.
  {
    name: "Check docker-compose config",
    command: "docker-compose config",
    args: { chdir: V.nextcloud_home },
    changed_when: false,
  },
  // This is the recommended way of doing scheduled jobs in large nextcloud
  // installations.
  {
    name: "Add nextcloud cron to crontab",
    cron: {
      job:
        tmpl`cd ${V.nextcloud_home} && docker compose exec -T -u www-data app php -f /var/www/html/cron.php || :`,
      hour: "*",
      minute: "*/5",
      name: "nextcloud_cron",
    },
  },
] satisfies TaskFile;
