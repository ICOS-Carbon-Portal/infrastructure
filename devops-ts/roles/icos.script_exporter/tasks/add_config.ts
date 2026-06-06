import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Add config to script-exporters config.yaml",
    blockinfile: {
      path: V.sexp_config,
      create: false,
      marker: tmpl`# {mark} ${V.sexp_marker}`,
      state: V.sexp_state.default("present"),
      insertafter: "EOF",
      block: V.sexp_block,
    },
    notify: "reload script-exporter",
  },
] satisfies TaskFile;
