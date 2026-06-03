import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create password file",
    copy: {
      dest: V.file,
      content: tmpl`${V.file_var}=${expr("lookup('vars', set_fact)")}`,
    },
    when: raw("lookup('vars', set_fact, default=False)"),
  },
  {
    name: "Generate password file",
    shell:
      tmpl`umask 0077; openssl rand -hex ${V.length} | awk '{ print \"${V.file_var}=\" $1 }' > ${V.file}`,
    args: {
      creates: V.file,
    },
  },
  {
    name: "Read password file",
    slurp: {
      src: V.file,
    },
    register: "_slurp",
  },
  {
    name: "Extract password",
    set_fact: tmpl`${V.set_fact}="${
      expr(
        "_slurp.content | b64decode | regex_replace('[^=]+=(\\\\S+)\\s*', '\\\\1')",
      )
    }"`,
  },
] satisfies TaskFile;
