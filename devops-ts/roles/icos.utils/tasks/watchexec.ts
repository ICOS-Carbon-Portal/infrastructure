import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { isNotDefined, not } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

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
    when: isNotDefined(V.watchexec_version),
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
    apt: { deb: V.watchexec_url_map.at(V.watchexec_architecture) },
  },
  {
    name: "Check that watchexec is executable and the correct version",
    shell: "watchexec --version | awk 'NR == 1 { print $2 }'",
    changed_when: false,
    register: _r,
    failed_when: not(_r.stdout.endswith(V.watchexec_version)),
  },
  {
    name: "Which version of watchexec was installed",
    debug: { msg: tmpl`Installed ${V.watchexec_version}` },
  },
] satisfies TaskFile;
