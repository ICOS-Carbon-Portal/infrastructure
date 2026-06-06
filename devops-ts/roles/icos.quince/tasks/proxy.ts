import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

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
