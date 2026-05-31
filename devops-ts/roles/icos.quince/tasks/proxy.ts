import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    import_role: "name=icos.nginxsite",
    vars: {
      nginxsite_name: expr("quince_name"),
      nginxsite_file: "quince.conf",
      nginxsite_domains: expr("quince_domains"),
    },
  },
] satisfies TaskFile;
