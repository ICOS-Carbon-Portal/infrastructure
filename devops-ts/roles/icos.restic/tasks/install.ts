import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    when: raw("restic_version is not defined"),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of restic",
        github_release: {
          user: "restic",
          repo: "restic",
          action: "latest_release",
        },
        register: "gh",
      },
      {
        name: "Set restic_version fact",
        set_fact: {
          restic_version: tmpl("{{ gh.tag.lstrip('v') }}"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Download restic",
    "ansible.builtin.shell": tmpl(
      "curl -L --silent {{ restic_url_map[restic_architecture] }} | bunzip2 > /usr/local/bin/restic && chmod +x /usr/local/bin/restic",
    ),
    args: {
      creates: tmpl(
        "{{ omit if restic_upgrade else '/usr/local/bin/restic' }}",
      ),
      executable: "/bin/bash",
    },
  },
  {
    name: "Check that restic is executable and the correct version",
    shell: "restic version",
    changed_when: false,
    register: "_r",
    failed_when: "restic_version not in _r.stdout",
  },
  {
    name: "Which version of restic was installed",
    debug: {
      msg: tmpl`Installed ${V.restic_version}`,
    },
  },
] satisfies TaskFile;
