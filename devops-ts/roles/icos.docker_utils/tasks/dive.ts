import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { isNotDefined, not } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

const gh = register("gh");
const _r = register("_r");

export default [
  {
    when: isNotDefined(V.dive_version),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of dive",
        github_release: {
          user: "wagoodman",
          repo: "dive",
          action: "latest_release",
        },
        register: gh,
      },
      {
        name: "Set dive_version fact",
        set_fact: {
          dive_version: gh.tag.ref.lstrip("v"),
          cacheable: true,
        },
      },
    ],
  },
  // FIXME: Remove in 2025
  {
    name: "Remove old install of /usr/local/sbin/dive",
    file: {
      name: "/usr/local/sbin/dive",
      state: "absent",
    },
  },
  {
    name: "Install dive",
    apt: {
      deb: V.dive_url_map.at(V.dive_architecture),
    },
  },
  {
    name: "Check that dive is executable and the correct version",
    shell: "dive --version",
    changed_when: false,
    register: _r,
    failed_when: not(_r.stdout.endswith(V.dive_version)),
  },
  {
    name: "Which version of dive was installed",
    debug: {
      msg: tmpl`Installed ${V.dive_version}`,
    },
  },
] satisfies TaskFile;
