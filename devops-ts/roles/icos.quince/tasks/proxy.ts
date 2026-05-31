import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    import_role: "name=icos.nginxsite",
    vars: {
      nginxsite_name: tmpl("{{ quince_name }}"),
      nginxsite_file: "quince.conf",
      nginxsite_domains: tmpl("{{ quince_domains }}"),
    },
  },
] satisfies TaskFile;
