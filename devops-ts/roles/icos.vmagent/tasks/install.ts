import {
  vmagent_bin,
  vmagent_configs,
  vmagent_fsd,
  vmagent_home,
  vmagent_upgrade,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { omit } from "../../../lib/builtins.ts";
import { loopOver } from "../../../lib/loop.ts";
import { register } from "../../../lib/register.ts";
import { type Tmpl, tmpl } from "../../../lib/template.ts";
import { group, not, or, truthy } from "../../../lib/vars.ts";

const _vmagent = register("_vmagent");

export default [
  loopOver<{ path: Tmpl; mode?: Tmpl }>(
    [
      { path: vmagent_home, mode: "0700" },
      { path: vmagent_bin },
      { path: vmagent_fsd },
      { path: vmagent_configs },
    ],
    (item) => ({
      name: "Create vmagent directories",
      file: {
        path: item.path,
        mode: item.mode.default(omit),
        state: "directory",
      },
    }),
  ),
  {
    name: "Check whether vmagent is installed",
    stat: {
      path: tmpl`${vmagent_bin}/vmagent-prod`,
    },
    register: _vmagent,
  },
  {
    name: "Install/upgrade install vmagent",
    import_tasks: "really_install.yml",
    when: or(
      not(_vmagent.stat.exists),
      group(truthy(vmagent_upgrade).default(false).bool()),
    ),
  },
] satisfies TaskFile;
