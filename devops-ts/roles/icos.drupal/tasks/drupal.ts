import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { isDef, rawTmpl, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create project directory",
    file: {
      path: V.project_dir,
      state: "directory",
    },
  },
  {
    name: "Pull source code from git",
    git: {
      repo: "https://github.com/ICOS-Carbon-Portal/drupal",
      version: V.git_version.default("master"),
      dest: V.project_dir,
      force: true,
    },
  },
  {
    name: tmpl`Create ${V.project_dir}/config/ directory`,
    file: tmpl`path=${V.project_dir}/config/ state=directory recurse=yes`,
  },
  {
    name: "Copy uploads config",
    copy: {
      src: "uploads.ini",
      dest: tmpl`${V.project_dir}/config/uploads.ini`,
    },
  },
  {
    name: tmpl`Create ${V.project_dir}/files/private/ directory`,
    file:
      tmpl`path=${V.project_dir}/files/private/ state=directory recurse=yes`,
  },
  {
    name: tmpl`Create ${V.project_dir}/files/default/files/ directory`,
    file:
      tmpl`path=${V.project_dir}/files/default/files/ state=directory recurse=yes`,
  },
  {
    name: "Copy settings.php",
    template: {
      src: "settings.php.j2",
      dest: tmpl`${V.project_dir}/files/default/settings.php`,
    },
  },
  {
    name: tmpl`Create ${V.project_dir}/docker/ directory`,
    file: tmpl`path=${V.project_dir}/docker/ state=directory recurse=yes`,
  },
  {
    name: "Copy docker-compose.yml",
    template: {
      src: "docker-compose.yml.j2",
      dest: tmpl`${V.project_dir}/docker/docker-compose.yml`,
    },
    register: "docker_compose_yml",
  },
  {
    name: "Copy environment file",
    template: {
      src: "env.j2",
      dest: tmpl`${V.project_dir}/docker/.env`,
    },
  },
  {
    name: tmpl`Create ${V.project_dir}/composer/ directory`,
    file: tmpl`path=${V.project_dir}/composer/ state=directory recurse=yes`,
  },
  {
    name: "Copy composer.json",
    template: {
      src: "composer.json.j2",
      dest: tmpl`${V.project_dir}/composer/composer.json`,
    },
  },
  {
    name: "Copy robots.txt",
    copy: {
      src: V.robots_txt,
      dest: tmpl`${V.project_dir}/composer/robots.txt.append`,
    },
    when: isDef("robots_txt"),
  },
  {
    name: "Enable maintenance mode",
    command: tmpl`docker exec ${
      rawTmpl("{{website}}")
    }_drupal_1 drush maint:set 1`,
    when: raw("update | bool"),
  },
  {
    name: "(Re)start docker containers",
    "community.docker.docker_compose_v2": {
      project_src: tmpl`${V.project_dir}/docker`,
      state: "present",
      pull: "always",
    },
  },
  {
    name: "Check private directory owner",
    command: tmpl`docker exec ${
      rawTmpl("{{website}}")
    }_drupal_1 stat -c '%U' /var/www/private/`,
    register: "private_directory_owner",
    changed_when: false,
  },
  {
    name: "Change private directory owner",
    command: tmpl`docker exec ${
      rawTmpl("{{website}}")
    }_drupal_1 chown -R www-data:www-data /var/www/private/`,
    when: raw('private_directory_owner.stdout != "www-data"'),
  },
  {
    name: "Check files directory owner",
    command: tmpl`docker exec ${
      rawTmpl("{{website}}")
    }_drupal_1 stat -c '%U' /var/www/private/`,
    register: "files_directory_owner",
    changed_when: false,
  },
  {
    name: "Change files directory owner",
    command: tmpl`docker exec ${
      rawTmpl("{{website}}")
    }_drupal_1 chown -R www-data:www-data /var/www/html/sites/default/files`,
    when: raw('files_directory_owner.stdout != "www-data"'),
  },
  {
    name: "Composer update",
    command: tmpl`docker exec ${
      rawTmpl("{{website}}")
    }_drupal_1 composer update`,
    when: raw("update | bool"),
    register: "result",
    changed_when: '"Package operations" in result.stderr',
  },
  {
    name: "Update database",
    command: tmpl`docker exec ${rawTmpl("{{website}}")}_drupal_1 drush updb`,
    when: raw("update | bool"),
  },
  {
    name: "Disable maintenance mode",
    command: tmpl`docker exec ${
      rawTmpl("{{website}}")
    }_drupal_1 drush maint:set 0`,
    when: raw("update | bool"),
  },
  {
    name: "Clear caches",
    command: tmpl`docker exec ${rawTmpl("{{website}}")}_drupal_1 drush cr`,
  },
] satisfies TaskFile;
