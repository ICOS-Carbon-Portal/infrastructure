import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create vmagent directories",
    file: {
      path: "{{ item.path }}",
      mode: "{{ item.mode | default(omit) }}",
      state: "directory",
    },
    loop: [
      { path: "{{ vmagent_home }}", mode: "0700" },
      { path: "{{ vmagent_bin }}" },
      { path: "{{ vmagent_fsd }}" },
      { path: "{{ vmagent_configs }}" },
    ],
  },
  {
    name: "Check whether vmagent is installed",
    stat: {
      path: "{{ vmagent_bin }}/vmagent-prod",
    },
    register: "_vmagent",
  },
  {
    name: "Install/upgrade install vmagent",
    import_tasks: "really_install.yml",
    when: raw(
      "not _vmagent.stat.exists or (vmagent_upgrade | default(False) | bool)",
    ),
  },
] satisfies TaskFile;
