import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  { import_tasks: "setup.yml", tags: "cpauth_setup" },
  {
    import_tasks: "deploy.yml",
    tags: "cpauth_deploy",
    // cpauth_jar_file is a role variable, so the typed isDefined() can't name it
    // (it isn't in the global Vars registry) — raw() is the auditable escape.
    when: raw("cpauth_jar_file is defined"),
  },
  { import_tasks: "backup.yml", tags: "cpauth_backup" },
] satisfies TaskFile;
