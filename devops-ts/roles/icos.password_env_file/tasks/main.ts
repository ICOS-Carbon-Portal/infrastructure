import { length } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { file, file_var, set_fact } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { lookup, tmpl } from "../../../lib/template.ts";
import { truthy } from "../../../lib/vars.ts";

const _slurp = register("_slurp");

export default [
  {
    name: "Create password file",
    copy: {
      dest: file,
      content: tmpl`${file_var}=${lookup("vars", set_fact)}`,
    },
    when: truthy(lookup("vars", set_fact, { default: false })),
  },
  {
    name: "Generate password file",
    shell:
      tmpl`umask 0077; openssl rand -hex ${length} | awk '{ print \"${file_var}=\" $1 }' > ${file}`,
    args: {
      creates: file,
    },
  },
  {
    name: "Read password file",
    slurp: {
      src: file,
    },
    register: _slurp,
  },
  {
    name: "Extract password",
    set_fact: tmpl`${set_fact}="${
      _slurp.content.ref.b64decode().regexReplace("[^=]+=(\\\\S+)\\s*", "\\\\1")
    }"`,
  },
] satisfies TaskFile;
