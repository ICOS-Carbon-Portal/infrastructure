import { type TaskFile } from "../../../lib/ansible/play.ts";
import { quince_domains, quince_name } from "../../../lib/paramvars.ts";

export default [
  {
    import_role: { name: "icos.nginxsite" },
    vars: {
      nginxsite_name: quince_name,
      nginxsite_file: "quince.conf",
      nginxsite_domains: quince_domains,
    },
  },
] satisfies TaskFile;
