import {
  and,
  group,
  isDefined,
  not,
  type TaskFile,
  truthy,
} from "../../../lib/ansible.ts";
import { rawTmpl, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: tmpl`Add ${V.username} user`,
    user: {
      name: V.username,
      groups: V.extra_groups,
      append: true,
      shell: "/bin/bash",
    },
    register: "_user",
  },
  {
    include_tasks: "jarfile.yml",
    when: not(group(truthy(V.jarservice_conf_only).default(false).bool())),
  },
  {
    name: tmpl`Copy ${V.servicename} config file ${V.configfile}`,
    template: {
      src: V.configfile,
      dest: tmpl`${rawTmpl("{{ _user.home}}")}/`,
    },
    notify: tmpl`restart ${V.servicename}`,
  },
  {
    name: tmpl`Copy ${V.servicename} nginx config file(s) ${
      rawTmpl("{{nginxconfig}}")
    }*`,
    template: {
      src: V.item,
      dest: "/etc/nginx/conf.d/",
    },
    with_fileglob: [tmpl`${rawTmpl("{{nginxconfig}}")}*`],
    // Our nginx config template is dependent on a variable set by
    // certbot. This means that if the certbot role is disabled, we
    // cannot deploy the config.
    when: and(isDefined(V.nginxconfig), not(V.certbot_disabled)),
    notify: "reload nginx config",
  },
  {
    name: tmpl`Add systemd ${V.servicename} servicefile`,
    template: {
      src: V.servicetemplate,
      dest: tmpl`/etc/systemd/system/${V.servicename}.service`,
    },
    notify: ["reload systemd config"],
  },
  {
    name: tmpl`Enable systemd ${V.servicename}`,
    service: tmpl`name=${V.servicename} enabled=yes state=started`,
  },
] satisfies TaskFile;
