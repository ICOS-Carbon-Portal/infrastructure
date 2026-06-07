import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "reload vmagent",
    shell:
      tmpl`${V.vmagent_bin}/vmagent-prod -dryRun -promscrape.config=${V.vmagent_home}/prometheus.yml && systemctl reload vmagent`,
    changed_when: false,
  },
  {
    name: "restart vmagent",
    systemd: {
      name: "vmagent",
      state: "restarted",
      daemon_reload: true,
    },
  },
] satisfies TaskFile;
