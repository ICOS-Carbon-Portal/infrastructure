import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Copy utilities",
    copy: {
      src: V.item,
      dest: tmpl`/usr/local/sbin/${V.item}`,
      mode: 0o755,
    },
    loop: ["lxdfs"],
  },
] satisfies TaskFile;
