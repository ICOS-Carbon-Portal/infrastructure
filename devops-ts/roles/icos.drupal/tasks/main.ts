import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: {
      msg: tmpl`${V.item} needs to be defined`,
    },
    when: raw("vars[item] is undefined"),
    loop: ["website"],
    tags: ["drupal", "drupal_nginx"],
  },
  {
    name: tmpl`Include ${expr("website")} vars`,
    include_vars: tmpl`${expr("website")}-vars.yml`,
    tags: ["drupal", "drupal_nginx"],
  },
  {
    name: tmpl`Include ${expr("website")} vault`,
    include_vars: tmpl`${expr("website")}-vault.yml`,
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
