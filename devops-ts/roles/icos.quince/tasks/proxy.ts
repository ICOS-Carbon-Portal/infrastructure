import { type TaskFile, V } from "../../../lib/ansible.ts";

export default [
  {
    import_role: "name=icos.nginxsite",
    vars: {
      nginxsite_name: V.quince_name,
      nginxsite_file: "quince.conf",
      nginxsite_domains: V.quince_domains,
    },
  },
] satisfies TaskFile;
