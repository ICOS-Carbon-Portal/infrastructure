import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: tmpl("Add {{ username }} user"),
    user: {
      name: tmpl("{{ username }}"),
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
    name: tmpl("Copy {{ servicename }} config file {{ configfile }}"),
    template: {
      src: tmpl("{{ configfile }}"),
      dest: tmpl("{{ _user.home}}/"),
    },
    notify: tmpl("restart {{ servicename }}"),
  },
  {
    name: tmpl("Copy {{ servicename }} nginx config file(s) {{nginxconfig}}*"),
    template: {
      src: V.item,
      dest: "/etc/nginx/conf.d/",
    },
    with_fileglob: [tmpl("{{nginxconfig}}*")],
    // Our nginx config template is dependent on a variable set by
    // certbot. This means that if the certbot role is disabled, we
    // cannot deploy the config.
    when: raw("nginxconfig is defined and not certbot_disabled"),
    notify: "reload nginx config",
  },
  {
    name: tmpl("Add systemd {{ servicename }} servicefile"),
    template: {
      src: tmpl("{{ servicetemplate }}"),
      dest: tmpl("/etc/systemd/system/{{ servicename }}.service"),
    },
    notify: ["reload systemd config"],
  },
  {
    name: tmpl("Enable systemd {{ servicename }}"),
    service: tmpl("name={{ servicename }} enabled=yes state=started"),
  },
] satisfies TaskFile;
