import { V } from "../_ctx.ts";
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
      { path: V.vmagent_home, mode: "0700" },
      { path: V.vmagent_bin },
      { path: V.vmagent_fsd },
      { path: V.vmagent_configs },
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
      path: tmpl`${V.vmagent_bin}/vmagent-prod`,
    },
    register: _vmagent,
  },
  {
    name: "Install/upgrade install vmagent",
    import_tasks: "really_install.yml",
    when: or(
      not(_vmagent.stat.exists),
      group(truthy(V.vmagent_upgrade).default(false).bool()),
    ),
  },
] satisfies TaskFile;
