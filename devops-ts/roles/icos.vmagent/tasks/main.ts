import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  { import_tasks: "install.yml", tags: "vmagent_install" },
  { import_tasks: "systemd.yml", tags: "vmagent_systemd" },
  {
    when: raw('vmagent_proxy != "disabled"'),
    import_tasks: "proxy.yml",
    tags: "vmagent_proxy",
  },
  { import_tasks: "just.yml", tags: "vmagent_just" },
] satisfies TaskFile;
