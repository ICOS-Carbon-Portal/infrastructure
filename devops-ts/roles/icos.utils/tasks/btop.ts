import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    when: raw("btop_version is not defined"),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of btop",
        github_release: {
          user: "aristocratos",
          repo: "btop",
          action: "latest_release",
        },
        register: "gh",
      },
      {
        name: "Set btop_version fact",
        set_fact: {
          btop_version: expr("gh.tag.lstrip('v')"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Unarchive btop",
    unarchive: {
      remote_src: true,
      src: expr("btop_url_map[ansible_architecture]"),
      dest: "/opt",
    },
    register: "unarchive",
  },
  {
    name: "Create /usr/local/bin/btop symlink",
    file: {
      dest: "/usr/local/bin/btop",
      src: tmpl`${expr("unarchive.dest")}/btop/bin/btop`,
      state: "link",
    },
  },
  {
    name: "Check that btop is executable",
    shell: "btop --version",
    changed_when: false,
    register: "_r",
  },
  {
    name: "Which version of btop was installed",
    debug: { msg: tmpl`Installed ${expr("_r.stdout")}` },
  },
] satisfies TaskFile;
