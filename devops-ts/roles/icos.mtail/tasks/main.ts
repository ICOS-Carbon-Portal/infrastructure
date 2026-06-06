import { mtail_host, mtail_logs, mtail_port, mtail_programs } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { loopOver } from "../../../lib/loop.ts";
import { register } from "../../../lib/register.ts";
import { type Tmpl, tmpl } from "../../../lib/template.ts";

const _find = register("_find");

export default [
  {
    name: "Install mtail",
    apt: {
      name: "mtail",
    },
  },
  loopOver<{ key: Tmpl; val: Tmpl }>(
    [
      { key: "LOGS", val: mtail_logs.join(",") },
      { key: "PORT", val: mtail_port },
      { key: "HOST", val: mtail_host },
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
      src: item,
      dest: "/etc/mtail",
      validate: "mtail --compile_only -port 0 --progs %s",
    },
    notify: "reload mtail",
    loop: mtail_programs,
  },
  {
    name: "Find unconfigured icos programs",
    find: {
      paths: "/etc/mtail",
      patterns: "icos-*.mtail",
      excludes: mtail_programs,
    },
    register: _find,
  },
  {
    name: "Remove unconfigured icos programs",
    file: {
      name: item,
      state: "absent",
    },
    notify: "reload mtail",
    loop: _find.files.ref.mapAttr("path"),
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
      url: tmpl`http://${mtail_host}:${mtail_port}`,
    },
    retries: 10,
  },
] satisfies TaskFile;
