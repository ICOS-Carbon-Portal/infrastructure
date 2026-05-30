import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Install packages",
    apt: {
      // needed by the justfile
      name: ["jq"],
    },
  },
  {
    name: "Create nebula user",
    user: {
      name: "{{ nebula_user }}",
      shell: "/usr/sbin/nologin",
      system: true,
      create_home: false,
    },
  },
  {
    name: "Create etc directory",
    file: {
      path: "{{ nebula_etc_dir }}",
      owner: "{{ nebula_user }}",
      group: "{{ nebula_user }}",
      state: "directory",
      mode: 0o700,
    },
  },
  {
    name: "Check whether nebula is already installed",
    stat: { path: "{{ nebula_bin_dir }}/nebula" },
    register: "_r",
  },
  {
    name: "Download and unpack nebula",
    include_tasks: "download.yml",
    when: raw("not _r.stat.exists or nebula_upgrade"),
  },
  {
    name: "Check that nebula runs",
    shell: `{{ nebula_bin_dir }}/{{ item }} -version
`,
    changed_when: false,
    register: "version",
    loop: ["nebula", "nebula-cert"],
  },
  {
    name: "Inform about installed version",
    run_once: true,
    debug: {
      msg: `We've installed nebula {{ version.results[0].stdout_lines[0] }}
`,
    },
    when: raw("not ansible_check_mode"),
  },
] satisfies TaskFile;
