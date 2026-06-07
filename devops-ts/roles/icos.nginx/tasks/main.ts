import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  { import_tasks: "setup.yml", tags: "nginx_setup" },
  { import_tasks: "certbot.yml", tags: "nginx_certbot" },
  { import_tasks: "testing.yml", tags: "nginx_testing" },
  {
    import_tasks: "metrics.yml",
    tags: "nginx_metrics",
    when: truthy(V.nginx_metrics_enable),
  },
] satisfies TaskFile;
