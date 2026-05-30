import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  { import_tasks: "setup.yml", tags: "cpmeta_setup" },
  {
    import_tasks: "deploy.yml",
    tags: "cpmeta_deploy",
    when: raw("cpmeta_jar_file is defined"),
  },
  {
    import_tasks: "restart.yml",
    tags: "cpmeta_restart",
    vars: {
      _restart_needed: true,
    },
  },
  {
    import_tasks: "backup.yml",
    tags: "cpmeta_backup",
    when: raw("cpmeta_backup_enable | default(False)"),
  },
] satisfies TaskFile;
