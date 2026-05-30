import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    import_tasks: "setup.yml",
    tags: "doi_setup",
  },
  {
    import_tasks: "deploy.yml",
    tags: "doi_deploy",
    when: raw("doi_jar_file is defined"),
  },
] satisfies TaskFile;
