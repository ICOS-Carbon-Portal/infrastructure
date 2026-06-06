import { type TaskFile } from "../../../lib/ansible/play.ts";
import { loopOver } from "../../../lib/loop.ts";
import { register } from "../../../lib/register.ts";
import { type Tmpl } from "../../../lib/template.ts";
import { tmpl, V } from "../_ctx.ts";

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
      { key: "LOGS", val: V.mtail_logs.join(",") },
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
    register: _find,
  },
  {
    name: "Remove unconfigured icos programs",
    file: {
      name: V.item,
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
      url: tmpl`http://${V.mtail_host}:${V.mtail_port}`,
    },
    retries: 10,
  },
] satisfies TaskFile;
