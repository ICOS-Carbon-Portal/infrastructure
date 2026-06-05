import { isUndefined, type TaskFile, varByName } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: {
      msg: tmpl`${V.item} needs to be defined`,
    },
    when: isUndefined(varByName(V.item)),
    loop: ["website"],
    tags: ["drupal", "drupal_nginx"],
  },
  {
    name: tmpl`Include ${V.website} vars`,
    include_vars: tmpl`${V.website}-vars.yml`,
    tags: ["drupal", "drupal_nginx"],
  },
  {
    name: tmpl`Include ${V.website} vault`,
    include_vars: tmpl`${V.website}-vault.yml`,
    tags: ["drupal", "drupal_nginx"],
  },
  {
    name: "Include vars",
    include_vars: "drupal.yml",
    tags: ["drupal", "drupal_nginx"],
  },
  { import_tasks: "nginx.yml", tags: "drupal_nginx" },
  { import_tasks: "drupal.yml", tags: "drupal" },
  { import_tasks: "backup.yml", tags: "drupal_backup" },
] satisfies TaskFile;
