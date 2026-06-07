import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";

const _textfiles = register("_textfiles");

export default [
  { import_tasks: "setup.yml", tags: "bbserver_setup" },
  { import_tasks: "cli.yml", tags: "bbserver_cli" },
  {
    name: tmpl`Check whether ${V.bbserver_textfiles} exists`,
    tags: "bbserver_monitor",
    stat: { path: V.bbserver_textfiles },
    register: _textfiles,
  },
  {
    import_tasks: "monitor.yml",
    tags: "bbserver_monitor",
    // Only enable monitoring via node_exporter if its textfiles directory exist.
    when: _textfiles.stat.exists,
  },
] satisfies TaskFile;
