import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    include_role: {
      name: "icos.bbclient2",
      public: true,
    },
    vars: {
      bbclient_name: "drupal",
      bbclient_home: tmpl`${V.drupal_home}/.bbclient`,
      bbclient_timer_conf: `OnCalendar=daily
RandomizedDelaySec=1h
`,
      bbclient_timer_content: "{{ lookup('template', 'borgbackup.sh') }}",
    },
  },
] satisfies TaskFile;
