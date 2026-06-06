import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Create nextcloud-exporter config file",
    copy: {
      dest: V.nextcloud_exporter_conf_host,
      mode: "og-w",
      content:
        `# https://github.com/xperimental/nextcloud-exporter#configuration-file
server: "https://{{ nextcloud_domain }}"
username: "nextcloud-exporter"
password: "{{ nextcloud_exporter_pass }}"
`,
    },
  },
] satisfies TaskFile;
