import {
  nebula_bin_dir,
  nebula_etc_dir,
  nebula_upgrade,
  nebula_user,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { ansible_check_mode } from "../../../lib/builtins.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { not, or, truthy } from "../../../lib/vars.ts";

const _r = register("_r");

export default [
  {
    name: "Install packages",
    apt: {
      // needed by the justfile
      name: ["jq"],
    },
  },
  {
    name: "Create nebula user",
    user: {
      name: nebula_user,
      shell: "/usr/sbin/nologin",
      system: true,
      create_home: false,
    },
  },
  {
    name: "Create etc directory",
    file: {
      path: nebula_etc_dir,
      owner: nebula_user,
      group: nebula_user,
      state: "directory",
      mode: 0o700,
    },
  },
  {
    name: "Check whether nebula is already installed",
    stat: { path: tmpl`${nebula_bin_dir}/nebula` },
    register: _r,
  },
  {
    name: "Download and unpack nebula",
    include_tasks: "download.yml",
    when: or(not(_r.stat.exists), truthy(nebula_upgrade)),
  },
  {
    name: "Check that nebula runs",
    shell: `{{ nebula_bin_dir }}/{{ item }} -version
`,
    changed_when: false,
    register: "version",
    loop: ["nebula", "nebula-cert"],
  },
  {
    name: "Inform about installed version",
    run_once: true,
    debug: {
      msg: `We've installed nebula {{ version.results[0].stdout_lines[0] }}
`,
    },
    when: not(ansible_check_mode),
  },
] satisfies TaskFile;
