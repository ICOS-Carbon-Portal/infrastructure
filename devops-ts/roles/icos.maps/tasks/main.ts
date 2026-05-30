import { type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    include_role: {
      name: "icos.nginxsite",
    },
    vars: {
      nginxsite_name: "maps",
      nginxsite_file: "maps-nginx.conf",
      nginxsite_domains: V.maps_domains,
    },
  },
] satisfies TaskFile;
