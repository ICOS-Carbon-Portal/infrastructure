import {
  lookup,
  register,
  type TaskFile,
  truthy,
} from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const _slurp = register("_slurp");

export default [
  {
    name: "Create password file",
    copy: {
      dest: V.file,
      content: tmpl`${V.file_var}=${lookup("vars", V.set_fact)}`,
    },
    when: truthy(lookup("vars", V.set_fact, { default: false })),
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
    register: _slurp,
  },
  {
    name: "Extract password",
    set_fact: tmpl`${V.set_fact}="${
      _slurp.content.ref.b64decode().regexReplace("[^=]+=(\\\\S+)\\s*", "\\\\1")
    }"`,
  },
] satisfies TaskFile;
