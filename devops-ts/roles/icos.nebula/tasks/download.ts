import { nebula_bin_dir, nebula_url_map, nebula_version } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { ansible_architecture } from "../../../lib/builtins.ts";
import { register } from "../../../lib/register.ts";
import { isNotDefined } from "../../../lib/vars.ts";

const gh = register("gh");

export default [
  {
    when: isNotDefined(nebula_version),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of nebula",
        github_release: {
          user: "slackhq",
          repo: "nebula",
          action: "latest_release",
        },
        register: gh,
      },
      {
        name: "Set nebula_version fact",
        set_fact: {
          nebula_version: gh.tag.ref.lstrip("v"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Install nebula",
    unarchive: {
      remote_src: true,
      src: nebula_url_map.at(ansible_architecture),
      dest: nebula_bin_dir,
      extra_opts: ["--no-same-owner"],
    },
    notify: "restart nebula",
  },
] satisfies TaskFile;
