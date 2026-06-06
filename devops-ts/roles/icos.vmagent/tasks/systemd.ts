import { vmagent_conf, vmagent_environ, vmagent_home } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Create prometheus.yml",
    copy: {
      dest: tmpl`${vmagent_home}/prometheus.yml`,
      content: vmagent_conf,
    },
    notify: "reload vmagent",
  },
  {
    name: "Create vmagent environ file",
    template: {
      dest: vmagent_environ,
      src: "vmagent.environ",
      mode: "0600",
      lstrip_blocks: true,
    },
    notify: "restart vmagent",
  },
  {
    name: "Create vmagent service file",
    template: {
      dest: tmpl`${vmagent_home}/vmagent.service`,
      lstrip_blocks: true,
      src: "vmagent.service",
    },
    notify: "restart vmagent",
  },
  {
    name: "Link service",
    command: tmpl`systemctl link ${vmagent_home}/vmagent.service`,
    args: {
      creates: "/etc/systemd/system/vmagent.service",
    },
  },
  {
    name: "Start vmagent service",
    systemd: {
      name: "vmagent",
      state: "started",
      enabled: true,
    },
  },
] satisfies TaskFile;
