import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    when: raw('vmagent_proxy == "probe"'),
    name: "Probe for vmagent_proxy fact",
    check_mode: false,
    shellfact: {
      exec: "ss -Htlp 'sport 443' | sed -re 's/.*(nginx|caddy).*/\\1/' | uniq",
      fact: "vmagent_proxy",
    },
  },
  {
    when: raw("vmagent_proxy not in ('nginx', 'caddy')"),
    check_mode: false,
    name: "Fail if we can't figure out which proxy server is used",
    fail: {
      msg: tmpl`Unknown proxy server "${V.vmagent_proxy}".\n`,
    },
  },
  {
    when: raw("vmagent_proxy == 'nginx'"),
    name: "Setup nginx proxy for vmagent",
    include_role: {
      name: "icos.nginxsite",
    },
  },
  {
    when: raw("vmagent_proxy == 'caddy'"),
    name: "Setup caddy proxy for vmagent",
    include_role: {
      name: "icos.caddy",
      tasks_from: "site.yml",
    },
  },
  {
    name: "Flush handlers",
    meta: "flush_handlers",
  },
  {
    when: raw("vmagent_auth"),
    block: [
      {
        name: "Test that the vmagent UI is password protected",
        uri: {
          url: tmpl`https://${V.inventory_hostname}/vmagent/`,
        },
        retries: 10,
        register: "r",
        failed_when: "r.status != 401",
      },
      {
        name: "Test that the vmagent UI works with password",
        uri: {
          url: tmpl`https://${V.inventory_hostname}/vmagent/`,
          user: expr("vmagent_auth.username"),
          password: expr("vmagent_auth.password"),
        },
        retries: 10,
        register: "r",
      },
    ],
  },
] satisfies TaskFile;
