import { vmagent_proxy } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { inventory_hostname } from "../../../lib/builtins.ts";
import { vmagent_auth } from "../../../lib/globals.ts";
import { tmpl } from "../../../lib/template.ts";
import { eq, notIn, truthy } from "../../../lib/vars.ts";

export default [
  {
    when: eq(vmagent_proxy, "probe"),
    name: "Probe for vmagent_proxy fact",
    check_mode: false,
    shellfact: {
      exec: "ss -Htlp 'sport 443' | sed -re 's/.*(nginx|caddy).*/\\1/' | uniq",
      fact: "vmagent_proxy",
    },
  },
  {
    when: notIn(vmagent_proxy, ["nginx", "caddy"]),
    check_mode: false,
    name: "Fail if we can't figure out which proxy server is used",
    fail: {
      msg: tmpl`Unknown proxy server "${vmagent_proxy}".\n`,
    },
  },
  {
    when: eq(vmagent_proxy, "nginx"),
    name: "Setup nginx proxy for vmagent",
    include_role: {
      name: "icos.nginxsite",
    },
  },
  {
    when: eq(vmagent_proxy, "caddy"),
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
    when: truthy(vmagent_auth),
    block: [
      {
        name: "Test that the vmagent UI is password protected",
        uri: {
          url: tmpl`https://${inventory_hostname}/vmagent/`,
        },
        retries: 10,
        register: "r",
        failed_when: "r.status != 401",
      },
      {
        name: "Test that the vmagent UI works with password",
        uri: {
          url: tmpl`https://${inventory_hostname}/vmagent/`,
          user: vmagent_auth.username,
          password: vmagent_auth.password,
        },
        retries: 10,
        register: "r",
      },
    ],
  },
] satisfies TaskFile;
