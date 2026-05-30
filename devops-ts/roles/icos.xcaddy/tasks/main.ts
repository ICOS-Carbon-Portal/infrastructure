import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  { import_role: "name=icos.golang" },
  {
    import_tasks: "xcaddy-debian.yml",
    when: raw("ansible_distribution_file_variety == 'Debian'"),
  },
  {
    import_tasks: "xcaddy-other.yml",
    when: raw("ansible_distribution_file_variety != 'Debian'"),
  },
] satisfies TaskFile;
