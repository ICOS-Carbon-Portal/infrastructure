import { vm_graf_plugins, vm_upgrade } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { omit } from "../../../lib/builtins.ts";
import { grafana_datasource_version } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { concat, iff, tmpl } from "../../../lib/template.ts";
import { hostvar, isNotDefined } from "../../../lib/vars.ts";

const gh = register("gh");

export default [
  {
    when: isNotDefined(grafana_datasource_version),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of grafana_datasource",
        github_release: {
          user: "VictoriaMetrics",
          repo: "grafana-datasource",
          action: "latest_release",
        },
        register: gh,
      },
      {
        name: "Set grafana_datasource_version fact",
        set_fact: {
          grafana_datasource_version: gh.tag.ref.lstrip("v"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Create grafana plugin directory",
    file: {
      path: vm_graf_plugins,
      state: "directory",
    },
  },
  {
    name: "Install victoriametrics grafana-datasource",
    unarchive: {
      src:
        tmpl`https://github.com/VictoriaMetrics/victoriametrics-datasource/releases/download/v${
          hostvar("localhost").grafana_datasource_version
        }/victoriametrics-metrics-datasource-v${
          hostvar("localhost").grafana_datasource_version
        }.zip`,
      dest: vm_graf_plugins,
      remote_src: true,
      creates: iff(
        vm_upgrade,
        omit,
        concat(vm_graf_plugins, "/victoriametrics-datasource"),
      ),
    },
    diff: false,
  },
  {
    name: "Which version of grafana-datasource was installed",
    debug: {
      msg: tmpl`Installed ${hostvar("localhost").grafana_datasource_version}`,
    },
  },
] satisfies TaskFile;
