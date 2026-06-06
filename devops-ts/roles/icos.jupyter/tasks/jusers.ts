import { jusers_home, jusers_venv } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { virtualenv_recreate } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  // After a do-release-upgrade, the python version will have changed and broken
  // the virtual environments.
  {
    name: "Remove virtual env",
    file: {
      path: jusers_venv,
      state: "absent",
    },
    when: truthy(virtualenv_recreate).default(false).bool(),
  },
  {
    name: "Create virtual env",
    pip: {
      virtualenv: jusers_venv,
      name: ["ruamel.yaml", "click", "pandas", "requests"],
      state: "present",
    },
  },
  {
    name: "Copy jusers.py",
    template: {
      src: "jusers.py",
      dest: tmpl`${jusers_home}/jusers.py`,
      mode: "+x",
      backup: true,
    },
  },
  {
    name: "Copy plugins",
    copy: {
      src: "plugins",
      dest: tmpl`${jusers_home}/`,
    },
  },
  {
    name: "Copy readme_template.html",
    copy: {
      src: "readme_template.html",
      dest: "/root/readme_template.html",
      backup: true,
    },
  },
  {
    name: "Create /usr/local/sbin/jusers symlink",
    file: {
      dest: "/usr/local/sbin/jusers",
      src: tmpl`${jusers_home}/jusers.py`,
      state: "link",
    },
  },
  {
    name: "Check that jusers executes",
    shell: "/usr/local/sbin/jusers",
    changed_when: false,
  },
] satisfies TaskFile;
