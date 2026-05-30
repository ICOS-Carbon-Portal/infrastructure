import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    import_tasks: "config_present.yml",
    when: raw('telegraf_config_state == "present"'),
  },
  {
    import_tasks: "config_absent.yml",
    when: raw('telegraf_config_state == "absent"'),
  },
] satisfies TaskFile;
