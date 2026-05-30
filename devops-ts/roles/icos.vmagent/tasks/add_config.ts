import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  { import_tasks: "assert_installed.yml" },
  {
    name: "Add a vmagent scrape config",
    copy: {
      dest: "{{ vmagent_configs }}/{{ vmagent_config_dest }}",
      content: "{{ vmagent_config_content }}",
    },
    notify: "reload vmagent",
  },
] satisfies TaskFile;
