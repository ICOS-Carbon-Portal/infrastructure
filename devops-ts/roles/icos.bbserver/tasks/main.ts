import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  { import_tasks: "setup.yml", tags: "bbserver_setup" },
  { import_tasks: "cli.yml", tags: "bbserver_cli" },
  {
    name: "Check whether {{ bbserver_textfiles }} exists",
    tags: "bbserver_monitor",
    stat: { path: "{{ bbserver_textfiles }}" },
    register: "_textfiles",
  },
  {
    import_tasks: "monitor.yml",
    tags: "bbserver_monitor",
    // Only enable monitoring via node_exporter if its textfiles directory exist.
    when: raw("_textfiles.stat.exists"),
  },
] satisfies TaskFile;
