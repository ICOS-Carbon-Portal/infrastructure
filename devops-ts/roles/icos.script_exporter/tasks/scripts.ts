import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Clone textfile-collector-scripts",
    git: {
      repo:
        "https://github.com/prometheus-community/node-exporter-textfile-collector-scripts",
      version: "master",
      dest: V.sexp_scripts_repo,
    },
    diff: false,
  },
  {
    name: "Create virtual env for scripts",
    pip: {
      virtualenv: V.sexp_scripts_venv,
      name: [
        "prometheus_client",
        "{{ 'docker' if 'smartmon' in sexp_exporters else omit }}",
      ],
    },
  },
  {
    name: "Install utils needed for the collector-scripts",
    apt: {
      name: [
        "moreutils",
        "{{ 'smartmontools' if 'smartmon' in sexp_exporters else omit }}",
      ],
    },
  },
] satisfies TaskFile;
