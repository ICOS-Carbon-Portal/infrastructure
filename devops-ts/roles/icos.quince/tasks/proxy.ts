import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    import_role: "name=icos.nginxsite",
    vars: {
      nginxsite_name: "{{ quince_name }}",
      nginxsite_file: "quince.conf",
      nginxsite_domains: "{{ quince_domains }}",
    },
  },
] satisfies TaskFile;
