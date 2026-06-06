import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { filedrop_domain } from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";
import { isUndefined, varByName } from "../../../lib/vars.ts";

export default [
  {
    name: "Check that all parameters are defined",
    fail: { msg: tmpl`${item} needs to be defined` },
    when: isUndefined(varByName(item)),
    loop: [
      "nginxsite_name",
      "filedrop_host",
      "filedrop_domain",
    ],
  },
  {
    include_role: "name=icos.certbot2",
    vars: {
      certbot_name: filedrop_domain,
      certbot_domains: [
        filedrop_domain,
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
