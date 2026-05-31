import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    when: raw("trippy_version is not defined"),
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
        register: "gh",
      },
      {
        name: "Set trippy_version fact",
        set_fact: {
          trippy_version: expr("gh.tag.lstrip('v')"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Install trippy",
    unarchive: {
      remote_src: true,
      src: expr("trippy_url_map[ansible_architecture]"),
      dest: "/usr/local/bin",
      extra_opts: ["--strip-components=1"],
    },
  },
  {
    name: "Check that trippy is executable and the correct version",
    shell: "trip --version",
    changed_when: false,
    register: "_r",
    failed_when: "not _r.stdout.endswith(trippy_version)",
  },
  {
    name: "Which version of trippy was installed",
    debug: { msg: tmpl`Installed ${V.trippy_version}` },
  },
] satisfies TaskFile;
