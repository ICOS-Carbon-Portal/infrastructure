import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    name: "Add config to script-exporters config.yaml",
    blockinfile: {
      path: expr("sexp_config"),
      create: false,
      marker: tmpl`# {mark} ${expr("sexp_marker")}`,
      state: expr("sexp_state | default('present')"),
      insertafter: "EOF",
      block: expr("sexp_block"),
    },
    notify: "reload script-exporter",
  },
] satisfies TaskFile;
