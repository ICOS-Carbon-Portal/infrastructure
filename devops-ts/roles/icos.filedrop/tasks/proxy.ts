import { type TaskFile } from "../../../lib/ansible/play.ts";
import { isUndefined, varByName } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: { msg: tmpl`${V.item} needs to be defined` },
    when: isUndefined(varByName(V.item)),
    loop: [
      "nginxsite_name",
      "filedrop_host",
      "filedrop_domain",
    ],
  },
  {
    include_role: "name=icos.certbot2",
    vars: {
      certbot_name: V.filedrop_domain,
      certbot_domains: [
        V.filedrop_domain,
      ],
    },
  },
  {
    include_role: "name=icos.nginxsite",
    vars: {
      nginxsite_file: "filedrop-nginx.conf",
    },
  },
] satisfies TaskFile;
