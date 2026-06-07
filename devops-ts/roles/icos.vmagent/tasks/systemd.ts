import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Create prometheus.yml",
    copy: {
      dest: tmpl`${V.vmagent_home}/prometheus.yml`,
      content: V.vmagent_conf,
    },
    notify: "reload vmagent",
  },
  {
    name: "Create vmagent environ file",
    template: {
      dest: V.vmagent_environ,
      src: "vmagent.environ",
      mode: "0600",
      lstrip_blocks: true,
    },
    notify: "restart vmagent",
  },
  {
    name: "Create vmagent service file",
    template: {
      dest: tmpl`${V.vmagent_home}/vmagent.service`,
      lstrip_blocks: true,
      src: "vmagent.service",
    },
    notify: "restart vmagent",
  },
  {
    name: "Link service",
    command: tmpl`systemctl link ${V.vmagent_home}/vmagent.service`,
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
