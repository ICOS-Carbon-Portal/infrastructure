import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  { import_tasks: "setup.yml", tags: "nextcloud_setup" },
  { import_tasks: "nginx.yml", tags: "nextcloud_nginx" },
  {
    import_tasks: "prometheus.yml",
    tags: "nextcloud_prometheus",
    when: raw("nextcloud_exporter_pass is defined"),
  },
  { import_tasks: "just.yml", tags: "nextcloud_just" },
] satisfies TaskFile;
