import {
  watchexec_architecture,
  watchexec_url_map,
  watchexec_version,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { isNotDefined, not } from "../../../lib/vars.ts";

const gr = register("gr");
const _r = register("_r");

export default [
  // Used to be a symlink to /opt/download/watchexec.
  // FIXME: Remove in 2025
  {
    name: "Remove /usr/local/sbin/watchexec",
    file: {
      name: "/usr/local/sbin/watchexec",
      state: "absent",
    },
  },
  {
    when: isNotDefined(watchexec_version),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of watchexec",
        github_release: {
          user: "watchexec",
          repo: "watchexec",
          action: "latest_release",
        },
        register: gr,
      },
      {
        name: "Set watchexec_version fact",
        set_fact: {
          watchexec_version: gr.tag.ref.lstrip("v"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Install watchexec",
    apt: { deb: watchexec_url_map.at(watchexec_architecture) },
  },
  {
    name: "Check that watchexec is executable and the correct version",
    shell: "watchexec --version | awk 'NR == 1 { print $2 }'",
    changed_when: false,
    register: _r,
    failed_when: not(_r.stdout.endswith(watchexec_version)),
  },
  {
    name: "Which version of watchexec was installed",
    debug: { msg: tmpl`Installed ${watchexec_version}` },
  },
] satisfies TaskFile;
