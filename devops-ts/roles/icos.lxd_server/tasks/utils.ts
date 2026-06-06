import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Copy utilities",
    copy: {
      src: item,
      dest: tmpl`/usr/local/sbin/${item}`,
      mode: 0o755,
    },
    loop: ["lxdfs"],
  },
] satisfies TaskFile;
