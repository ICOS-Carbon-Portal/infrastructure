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
    when: isNotDefined(V.just_version),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of just",
        github_release: {
          user: "casey",
          repo: "just",
          action: "latest_release",
        },
        register: gh,
      },
      {
        name: "Set just_version fact",
        set_fact: {
          just_version: gh.tag.ref.lstrip("v"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Install just",
    unarchive: {
      remote_src: true,
      src: V.just_url_map.at(ansible_architecture),
      dest: "/usr/local/bin",
      include: ["just"],
    },
  },
  {
    name: "Check that just is executable and the correct version",
    shell: "just --version",
    changed_when: false,
    register: _r,
    failed_when: not(_r.stdout.endswith(V.just_version)),
  },
  {
    name: "Which version of just was installed",
    debug: { msg: tmpl`Installed ${V.just_version}` },
  },
] satisfies TaskFile;
