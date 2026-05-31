import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, rawTmpl, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: tmpl`Add ${expr("username")} user`,
    user: {
      name: expr("username"),
      groups: V.extra_groups,
      append: true,
      shell: "/bin/bash",
    },
    register: "_user",
  },
  {
    include_tasks: "jarfile.yml",
    when: raw("not (jarservice_conf_only | default(False) | bool)"),
  },
  {
    name: tmpl`Copy ${expr("servicename")} config file ${expr("configfile")}`,
    template: {
      src: expr("configfile"),
      dest: tmpl`${rawTmpl("{{ _user.home}}")}/`,
    },
    notify: tmpl`restart ${expr("servicename")}`,
  },
  {
    name: tmpl`Copy ${expr("servicename")} nginx config file(s) ${
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
    when: raw("nginxconfig is defined and not certbot_disabled"),
    notify: "reload nginx config",
  },
  {
    name: tmpl`Add systemd ${expr("servicename")} servicefile`,
    template: {
      src: expr("servicetemplate"),
      dest: tmpl`/etc/systemd/system/${expr("servicename")}.service`,
    },
    notify: ["reload systemd config"],
  },
  {
    name: tmpl`Enable systemd ${expr("servicename")}`,
    service: tmpl`name=${expr("servicename")} enabled=yes state=started`,
  },
] satisfies TaskFile;
