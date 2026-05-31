import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    when: raw("uv_version is not defined"),
    run_once: true,
    check_mode: false,
    delegate_to: "localhost",
    delegate_facts: true,
    block: [
      {
        name: "Find the latest release of uv",
        github_release: {
          user: "astral-sh",
          repo: "uv",
          action: "latest_release",
        },
        register: "gh",
      },
      {
        name: "Set uv_version fact",
        set_fact: {
          uv_version: tmpl("{{ gh.tag.lstrip('v') }}"),
          cacheable: true,
        },
      },
    ],
  },
  {
    name: "Install uv",
    unarchive: {
      owner: "root",
      group: "root",
      remote_src: true,
      src: tmpl("{{ uv_url_map[uv_architecture] }}"),
      // Only two binaries, uv and uvx
      dest: "/usr/local/bin",
      extra_opts: [
        // don't preserve ownership
        "--no-same-owner",
        // strip outer directory
        "--strip-components=1",
      ],
    },
  },
  {
    name: "Check that uv is executable and the correct version",
    shell: "/usr/local/bin/uv version",
    changed_when: false,
    register: "_r",
    failed_when: "not _r.stdout.endswith(uv_version)",
  },
  {
    name: "Which version of uv was installed",
    debug: {
      msg: tmpl`Installed ${V.uv_version}`,
    },
  },
] satisfies TaskFile;
