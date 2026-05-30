import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Add {{ username }} user",
    user: {
      name: "{{ username }}",
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
    name: "Copy {{ servicename }} config file {{ configfile }}",
    template: {
      src: "{{ configfile }}",
      dest: "{{ _user.home}}/",
    },
    notify: "restart {{ servicename }}",
  },
  {
    name: "Copy {{ servicename }} nginx config file(s) {{nginxconfig}}*",
    template: {
      src: V.item,
      dest: "/etc/nginx/conf.d/",
    },
    with_fileglob: ["{{nginxconfig}}*"],
    // Our nginx config template is dependent on a variable set by
    // certbot. This means that if the certbot role is disabled, we
    // cannot deploy the config.
    when: raw("nginxconfig is defined and not certbot_disabled"),
    notify: "reload nginx config",
  },
  {
    name: "Add systemd {{ servicename }} servicefile",
    template: {
      src: "{{ servicetemplate }}",
      dest: "/etc/systemd/system/{{ servicename }}.service",
    },
    notify: ["reload systemd config"],
  },
  {
    name: "Enable systemd {{ servicename }}",
    service: "name={{ servicename }} enabled=yes state=started",
  },
] satisfies TaskFile;
