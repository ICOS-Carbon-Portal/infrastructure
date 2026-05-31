import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: "Add config to script-exporters config.yaml",
    blockinfile: {
      path: tmpl("{{ sexp_config }}"),
      create: false,
      marker: tmpl("# {mark} {{ sexp_marker }}"),
      state: tmpl("{{ sexp_state | default('present') }}"),
      insertafter: "EOF",
      block: tmpl("{{ sexp_block }}"),
    },
    notify: "reload script-exporter",
  },
] satisfies TaskFile;
