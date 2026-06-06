import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  { import_tasks: "geoip_setup.yml", tags: "geoip_setup" },
  { import_tasks: "geoip_app.yml", tags: "geoip_app" },
  { import_role: "name=icos.certbot2", tags: "geoip_certbot" },
  {
    import_role: "name=icos.nginxsite",
    tags: "geoip_nginx",
    vars: {
      nginxsite_domains: [V.geoip_domain],
    },
  },
] satisfies TaskFile;
