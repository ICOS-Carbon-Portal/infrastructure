import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Add config to script-exporters config.yaml",
    blockinfile: {
      path: "{{ sexp_config }}",
      create: false,
      marker: "# {mark} {{ sexp_marker }}",
      state: "{{ sexp_state | default('present') }}",
      insertafter: "EOF",
      block: "{{ sexp_block }}",
    },
    notify: "reload script-exporter",
  },
] satisfies TaskFile;
