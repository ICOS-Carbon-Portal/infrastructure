import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { website } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { isUndefined, varByName } from "../../../lib/vars.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: {
      msg: tmpl`${item} needs to be defined`,
    },
    when: isUndefined(varByName(item)),
    loop: ["website"],
    tags: ["drupal", "drupal_nginx"],
  },
  {
    name: tmpl`Include ${website} vars`,
    include_vars: tmpl`${website}-vars.yml`,
    tags: ["drupal", "drupal_nginx"],
  },
  {
    name: tmpl`Include ${website} vault`,
    include_vars: tmpl`${website}-vault.yml`,
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
