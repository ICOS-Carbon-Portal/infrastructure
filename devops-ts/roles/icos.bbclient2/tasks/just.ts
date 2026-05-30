import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Copy justfile",
    template: {
      src: "justfile",
      dest: tmpl`${V.bbclient_home}/`,
      variable_start_string: "{{ '{{{{' }}",
      variable_end_string: "{{ '}}}}' }}",
      lstrip_blocks: true,
    },
  },
  {
    name: "Copy systemd-wide justfile",
    copy: {
      src: "ops-bbclient",
      dest: "/usr/local/bin/",
      mode: "+x",
    },
  },
] satisfies TaskFile;
