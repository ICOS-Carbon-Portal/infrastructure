import { isNotDefined, register, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const gh = register("gh");

export default [
  {
    when: isNotDefined(V.lazygit_version),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of lazygit",
        github_release: {
          user: "jesseduffield",
          repo: "lazygit",
          action: "latest_release",
        },
        register: gh,
      },
      {
        name: "Set lazygit_version fact",
        set_fact: {
          lazygit_version: gh.tag.ref.lstrip("v"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Install lazygit",
    unarchive: {
      owner: "root",
      group: "root",
      remote_src: true,
      src: V.lazygit_url_map.at(V.lazygit_architecture),
      dest: "/usr/local/bin/",
      // extract only this
      include: ["lazygit"],
      extra_opts: [
        // don't preserve ownership
        "--no-same-owner",
        // needed for globbing in "include:"
        "--wildcards",
      ],
    },
  },
  {
    name: "Check that lazygit is executable and the correct version",
    shell: "/usr/local/bin/lazygit --version",
    changed_when: false,
    register: "_r",
    failed_when: "not lazygit_version in _r.stdout",
  },
  {
    name: "Which version of lazygit was installed",
    debug: { msg: tmpl`Installed ${V.lazygit_version}` },
  },
] satisfies TaskFile;
