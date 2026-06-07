import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { ansible_architecture } from "../../../lib/builtins.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { isNotDefined, not } from "../../../lib/vars.ts";

const gh = register("gh");
const _r = register("_r");

export default [
  {
    when: isNotDefined(V.trippy_version),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of trippy",
        github_release: {
          user: "fujiapple852",
          repo: "trippy",
          action: "latest_release",
        },
        register: gh,
      },
      {
        name: "Set trippy_version fact",
        set_fact: {
          trippy_version: gh.tag.ref.lstrip("v"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Install trippy",
    unarchive: {
      remote_src: true,
      src: V.trippy_url_map.at(ansible_architecture),
      dest: "/usr/local/bin",
      extra_opts: ["--strip-components=1"],
    },
  },
  {
    name: "Check that trippy is executable and the correct version",
    shell: "trip --version",
    changed_when: false,
    register: _r,
    failed_when: not(_r.stdout.endswith(V.trippy_version)),
  },
  {
    name: "Which version of trippy was installed",
    debug: { msg: tmpl`Installed ${V.trippy_version}` },
  },
] satisfies TaskFile;
