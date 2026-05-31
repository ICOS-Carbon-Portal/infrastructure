import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    when: raw("lazydocker_version is not defined"),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of lazydocker",
        github_release: {
          user: "jesseduffield",
          repo: "lazydocker",
          action: "latest_release",
        },
        register: "gh",
      },
      {
        name: "Set lazydocker_version fact",
        set_fact: {
          lazydocker_version: tmpl("{{ gh.tag.lstrip('v') }}"),
          cacheable: true,
        },
      },
    ],
  },
  // FIXME: Remove in 2025
  {
    name: "Remove old install of /usr/local/sbin/lazydocker",
    file: {
      name: "/usr/local/sbin/lazydocker",
      state: "absent",
    },
  },
  {
    name: "Install lazydocker",
    unarchive: {
      owner: "root",
      group: "root",
      remote_src: true,
      src: tmpl("{{ lazydocker_url_map[lazydocker_architecture] }}"),
      dest: "/usr/local/bin",
      include: [
        // extract only the binary (skip the readme etc)
        "lazydocker",
      ],
    },
    register: "_unarchive",
  },
  // Printing the installed version before we test for correct version makes it
  // easier to debug any mishaps.
  {
    name: "Which version of lazydocker was installed",
    debug: {
      msg: tmpl`Installed ${V.lazydocker_version}`,
    },
  },
  {
    name: "Check that lazydocker is executable and the correct version",
    shell: "lazydocker --version",
    changed_when: false,
    register: "_r",
    failed_when: "not _r.stdout_lines[0].endswith(lazydocker_version)",
  },
] satisfies TaskFile;
