import { hostvar, raw, register, type TaskFile } from "../../../lib/ansible.ts";
import { rawTmpl, tmpl, V } from "../_ctx.ts";

const gh = register("gh");

export default [
  {
    when: raw("grafana_datasource_version is not defined"),
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
      path: V.vm_graf_plugins,
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
      dest: V.vm_graf_plugins,
      remote_src: true,
      creates: rawTmpl(
        "{{omit if vm_upgrade else vm_graf_plugins + '/victoriametrics-datasource'}}",
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
