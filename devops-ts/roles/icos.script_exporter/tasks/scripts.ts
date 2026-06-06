import { type TaskFile } from "../../../lib/ansible/play.ts";
import { iff } from "../../../lib/template.ts";
import { isIn } from "../../../lib/vars.ts";
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
        iff(isIn("smartmon", V.sexp_exporters), "docker", V.omit),
      ],
    },
  },
  {
    name: "Install utils needed for the collector-scripts",
    apt: {
      name: [
        "moreutils",
        iff(isIn("smartmon", V.sexp_exporters), "smartmontools", V.omit),
      ],
    },
  },
] satisfies TaskFile;
