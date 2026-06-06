import { type TaskFile } from "../../../lib/ansible/play.ts";
import { jinjaLiteral } from "../../../lib/template.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Copy justfile",
    template: {
      src: "justfile",
      dest: tmpl`${V.bbclient_home}/`,
      variable_start_string: jinjaLiteral("{{{{"),
      variable_end_string: jinjaLiteral("}}}}"),
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
