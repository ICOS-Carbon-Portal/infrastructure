import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { jupyter_domain } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { isUndefined, varByName } from "../../../lib/vars.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: { msg: tmpl`${item} needs to be defined` },
    when: isUndefined(varByName(item)),
    loop: ["jupyter_domain"],
  },
  {
    include_role: { name: "icos.certbot2" },
    vars: {
      certbot_name: jupyter_domain,
      certbot_domains: [jupyter_domain],
    },
  },
  {
    include_role: { name: "icos.nginxsite" },
    vars: {
      nginxsite_file: "jupyter-nginx.conf",
      jupyter_cert_name: jupyter_domain,
    },
  },
] satisfies TaskFile;
