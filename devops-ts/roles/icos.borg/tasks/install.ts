import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    when: raw("borg_version is not defined"),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of borg",
        github_release: {
          user: "borgbackup",
          repo: "borg",
          action: "latest_release",
        },
        register: "gh",
      },
      {
        name: "Set borg_version fact",
        set_fact: {
          borg_version: tmpl("{{ gh.tag.lstrip('v') }}"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Architecture is not supported",
    fail: {
      msg: tmpl`borg is not supported on ${V.ansible_architecture}`,
    },
    when: raw('ansible_architecture in ("armv6l", "armv7l", "aarch64")'),
  },
  {
    name: "Download borg",
    get_url: {
      url: tmpl("{{ borg_url_map[ansible_architecture] }}"),
      dest: V.borg_bin,
      force: V.borg_upgrade,
      mode: "+x",
    },
  },
  {
    name: "Check that borg is executable and the correct version",
    shell: tmpl`${V.borg_bin} --version`,
    changed_when: false,
    register: "_r",
    failed_when: "not _r.stdout.endswith(borg_version)",
  },
  {
    name: "Which version of borg is installed",
    debug: {
      msg: tmpl`Installed ${V.borg_version}`,
    },
  },
] satisfies TaskFile;
