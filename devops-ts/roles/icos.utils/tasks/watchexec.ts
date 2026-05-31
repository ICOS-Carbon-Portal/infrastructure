import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  // Used to be a symlink to /opt/download/watchexec.
  // FIXME: Remove in 2025
  {
    name: "Remove /usr/local/sbin/watchexec",
    file: {
      name: "/usr/local/sbin/watchexec",
      state: "absent",
    },
  },
  {
    when: raw("watchexec_version is not defined"),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of watchexec",
        github_release: {
          user: "watchexec",
          repo: "watchexec",
          action: "latest_release",
        },
        register: "gr",
      },
      {
        name: "Set watchexec_version fact",
        set_fact: {
          watchexec_version: tmpl("{{ gr.tag.lstrip('v') }}"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Install watchexec",
    apt: { deb: tmpl("{{ watchexec_url_map[watchexec_architecture] }}") },
  },
  {
    name: "Check that watchexec is executable and the correct version",
    shell: "watchexec --version | awk 'NR == 1 { print $2 }'",
    changed_when: false,
    register: "_r",
    failed_when: "not _r.stdout.endswith(watchexec_version)",
  },
  {
    name: "Which version of watchexec was installed",
    debug: { msg: tmpl`Installed ${V.watchexec_version}` },
  },
] satisfies TaskFile;
