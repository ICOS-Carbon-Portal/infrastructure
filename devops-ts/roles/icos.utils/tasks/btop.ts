import { isNotDefined, register, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const gh = register("gh");

const _r = register("_r");
const unarchive = register("unarchive");

export default [
  {
    when: isNotDefined(V.btop_version),
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
        register: gh,
      },
      {
        name: "Set btop_version fact",
        set_fact: {
          btop_version: gh.tag.ref.lstrip("v"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Unarchive btop",
    unarchive: {
      remote_src: true,
      src: V.btop_url_map.at(V.ansible_architecture),
      dest: "/opt",
    },
    register: unarchive,
  },
  {
    name: "Create /usr/local/bin/btop symlink",
    file: {
      dest: "/usr/local/bin/btop",
      src: tmpl`${unarchive.dest.ref}/btop/bin/btop`,
      state: "link",
    },
  },
  {
    name: "Check that btop is executable",
    shell: "btop --version",
    changed_when: false,
    register: _r,
  },
  {
    name: "Which version of btop was installed",
    debug: { msg: tmpl`Installed ${_r.stdout.ref}` },
  },
] satisfies TaskFile;
