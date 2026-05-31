import {
  loopOver,
  raw,
  type TaskFile,
  type Tmpl,
} from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

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
        mode: tmpl("{{ item.mode | default(omit) }}"),
        state: "directory",
      },
    }),
  ),
  {
    name: "Check whether vmagent is installed",
    stat: {
      path: tmpl`${V.vmagent_bin}/vmagent-prod`,
    },
    register: "_vmagent",
  },
  {
    name: "Install/upgrade install vmagent",
    import_tasks: "really_install.yml",
    when: raw(
      "not _vmagent.stat.exists or (vmagent_upgrade | default(False) | bool)",
    ),
  },
] satisfies TaskFile;
