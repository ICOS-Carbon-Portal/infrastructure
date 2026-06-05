import { isDefined, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  { import_tasks: "setup.yml", tags: "nextcloud_setup" },
  { import_tasks: "nginx.yml", tags: "nextcloud_nginx" },
  {
    import_tasks: "prometheus.yml",
    tags: "nextcloud_prometheus",
    when: isDefined(V.nextcloud_exporter_pass),
  },
  { import_tasks: "just.yml", tags: "nextcloud_just" },
] satisfies TaskFile;
