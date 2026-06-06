import { type TaskFile } from "../../../lib/ansible/play.ts";
import {
  sexp_block,
  sexp_config,
  sexp_marker,
  sexp_state,
} from "../../../lib/paramvars.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Add config to script-exporters config.yaml",
    blockinfile: {
      path: sexp_config,
      create: false,
      marker: tmpl`# {mark} ${sexp_marker}`,
      state: sexp_state.default("present"),
      insertafter: "EOF",
      block: sexp_block,
    },
    notify: "reload script-exporter",
  },
] satisfies TaskFile;
