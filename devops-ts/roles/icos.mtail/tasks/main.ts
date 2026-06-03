import { loopOver, type TaskFile, type Tmpl } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Install mtail",
    apt: {
      name: "mtail",
    },
  },
  loopOver<{ key: Tmpl; val: Tmpl }>(
    [
      { key: "LOGS", val: expr("mtail_logs | join(',')") },
      { key: "PORT", val: V.mtail_port },
      { key: "HOST", val: V.mtail_host },
    ],
    (item) => ({
      name: "Configure mtail",
      lineinfile: {
        path: "/etc/default/mtail",
        regexp: tmpl`^#?${item.key}=`,
        line: tmpl`${item.key}=${item.val}`,
        state: "present",
        create: false,
      },
      notify: "reload mtail",
    }),
  ),
  {
    name: "Install configure icos programs",
    copy: {
      src: V.item,
      dest: "/etc/mtail",
      validate: "mtail --compile_only -port 0 --progs %s",
    },
    notify: "reload mtail",
    loop: V.mtail_programs,
  },
  {
    name: "Find unconfigured icos programs",
    find: {
      paths: "/etc/mtail",
      patterns: "icos-*.mtail",
      excludes: V.mtail_programs,
    },
    register: "_find",
  },
  {
    name: "Remove unconfigured icos programs",
    file: {
      name: V.item,
      state: "absent",
    },
    notify: "reload mtail",
    loop: expr("_find.files | map(attribute='path')"),
  },
  {
    name: "Start mtail service",
    systemd: {
      name: "mtail",
      enabled: true,
      state: "started",
    },
  },
  {
    name: "Check that the mtail http server is responding",
    uri: {
      url: tmpl`http://${V.mtail_host}:${V.mtail_port}`,
    },
    retries: 10,
  },
] satisfies TaskFile;
