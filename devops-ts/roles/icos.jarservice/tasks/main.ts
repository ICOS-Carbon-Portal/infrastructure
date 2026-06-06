import { certbot_disabled, extra_groups } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import {
  configfile,
  jarservice_conf_only,
  nginxconfig,
  servicename,
  servicetemplate,
  username,
} from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { and, group, isDefined, not, truthy } from "../../../lib/vars.ts";

const _user = register("_user");

export default [
  {
    name: tmpl`Add ${username} user`,
    user: {
      name: username,
      groups: extra_groups,
      append: true,
      shell: "/bin/bash",
    },
    register: _user,
  },
  {
    include_tasks: "jarfile.yml",
    when: not(group(truthy(jarservice_conf_only).default(false).bool())),
  },
  {
    name: tmpl`Copy ${servicename} config file ${configfile}`,
    template: {
      src: configfile,
      dest: tmpl`${_user.home.ref}/`,
    },
    notify: tmpl`restart ${servicename}`,
  },
  {
    name: tmpl`Copy ${servicename} nginx config file(s) ${nginxconfig}*`,
    template: {
      src: item,
      dest: "/etc/nginx/conf.d/",
    },
    with_fileglob: [tmpl`${nginxconfig}*`],
    // Our nginx config template is dependent on a variable set by
    // certbot. This means that if the certbot role is disabled, we
    // cannot deploy the config.
    when: and(isDefined(nginxconfig), not(certbot_disabled)),
    notify: "reload nginx config",
  },
  {
    name: tmpl`Add systemd ${servicename} servicefile`,
    template: {
      src: servicetemplate,
      dest: tmpl`/etc/systemd/system/${servicename}.service`,
    },
    notify: ["reload systemd config"],
  },
  {
    name: tmpl`Enable systemd ${servicename}`,
    service: tmpl`name=${servicename} enabled=yes state=started`,
  },
] satisfies TaskFile;
