import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "pip install docker",
    pip: {
      name: "docker",
      state: "present",
    },
  },
  {
    name: "Create dockermon timer",
    include_role: {
      name: "icos.timer",
    },
    vars: {
      timer_user: null,
      timer_home: V.dockermon_home,
      timer_name: "node-exporter-dockermon",
      timer_conf: "OnCalendar=*:0/5",
      timer_envs: [
        "PYTHONUNBUFFERED=1",
        "PATH=/usr/bin:/usr/local/bin",
      ],
      timer_content: expr("lookup('template', 'dockermon.py')"),
      timer_exec:
        tmpl`/bin/bash -c 'set -o pipefail && ${V.timer_dest} | uniq | sponge ${V.dockermon_prom}'`,
    },
  },
] satisfies TaskFile;
