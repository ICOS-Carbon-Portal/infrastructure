import { isNotDefined, register, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

const gh = register("gh");

export default [
  {
    when: isNotDefined(V.nebula_version),
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
      src: V.nebula_url_map.at(V.ansible_architecture),
      dest: V.nebula_bin_dir,
      extra_opts: ["--no-same-owner"],
    },
    notify: "restart nebula",
  },
] satisfies TaskFile;
