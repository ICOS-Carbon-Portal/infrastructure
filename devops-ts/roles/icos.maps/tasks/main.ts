import { maps_domains } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    include_role: {
      name: "icos.nginxsite",
    },
    vars: {
      nginxsite_name: "maps",
      nginxsite_file: "maps-nginx.conf",
      nginxsite_domains: maps_domains,
    },
  },
] satisfies TaskFile;
