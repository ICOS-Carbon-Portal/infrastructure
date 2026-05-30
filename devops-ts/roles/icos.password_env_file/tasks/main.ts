import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create password file",
    copy: {
      dest: "{{ file }}",
      content: "{{ file_var }}={{ lookup('vars', set_fact) }}",
    },
    when: raw("lookup('vars', set_fact, default=False)"),
  },
  {
    name: "Generate password file",
    shell:
      "umask 0077; openssl rand -hex {{ length }} | awk '{ print \"{{ file_var }}=\" $1 }' > {{ file }}",
    args: {
      creates: "{{ file }}",
    },
  },
  {
    name: "Read password file",
    slurp: {
      src: "{{ file }}",
    },
    register: "_slurp",
  },
  {
    name: "Extract password",
    set_fact:
      "{{ set_fact }}=\"{{ _slurp.content | b64decode | regex_replace('[^=]+=(\\\\S+)\\s*', '\\\\1') }}\"",
  },
] satisfies TaskFile;
