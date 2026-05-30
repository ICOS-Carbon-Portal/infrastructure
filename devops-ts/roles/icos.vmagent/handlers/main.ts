import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "reload vmagent",
    shell:
      "{{ vmagent_bin }}/vmagent-prod -dryRun -promscrape.config={{ vmagent_home }}/prometheus.yml && systemctl reload vmagent",
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
