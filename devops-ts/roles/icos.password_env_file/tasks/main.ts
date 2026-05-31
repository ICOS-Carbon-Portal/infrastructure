import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create password file",
    copy: {
      dest: tmpl("{{ file }}"),
      content: tmpl("{{ file_var }}={{ lookup('vars', set_fact) }}"),
    },
    when: raw("lookup('vars', set_fact, default=False)"),
  },
  {
    name: "Generate password file",
    shell:
      tmpl`umask 0077; openssl rand -hex ${V.length} | awk '{ print \"{{ file_var }}=\" $1 }' > {{ file }}`,
    args: {
      creates: tmpl("{{ file }}"),
    },
  },
  {
    name: "Read password file",
    slurp: {
      src: tmpl("{{ file }}"),
    },
    register: "_slurp",
  },
  {
    name: "Extract password",
    set_fact: tmpl(
      "{{ set_fact }}=\"{{ _slurp.content | b64decode | regex_replace('[^=]+=(\\\\S+)\\s*', '\\\\1') }}\"",
    ),
  },
] satisfies TaskFile;
