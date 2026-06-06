import { nexus_host_port } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { nexus_certbot_enable } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { not, truthy } from "../../../lib/vars.ts";

const r = register("r");

export default [
  {
    import_role: "name=icos.certbot2",
    when: truthy(nexus_certbot_enable).default(true),
  },
  {
    import_role: "name=icos.nginxsite",
  },
  {
    name: "Check that nexus responds with correct version",
    uri: {
      url: tmpl`http://127.0.0.1:${nexus_host_port}/service/local/status`,
      return_content: true,
    },
    register: r,
    failed_when: [
      'not (("<version>%s</version>" % nexus_version) in r.content)',
    ],
    // Give nexus a chance to come online
    retries: 2,
    delay: 10,
    until: not(r.failed),
  },
] satisfies TaskFile;
