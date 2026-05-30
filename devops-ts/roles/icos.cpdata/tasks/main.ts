import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  { import_tasks: "setup.yml", tags: "cpdata_setup" },
  {
    import_tasks: "deploy.yml",
    tags: "cpdata_deploy",
    when: raw("cpdata_jar_file is defined"),
  },
] satisfies TaskFile;
