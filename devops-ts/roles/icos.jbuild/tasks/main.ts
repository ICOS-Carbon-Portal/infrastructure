import { type TaskFile, V } from "../../../lib/ansible.ts";

export default [
  { import_tasks: "jbuild.yml", tags: "jbuild_jbuild" },
  { import_tasks: "users.yml", tags: "jbuild_users" },
  {
    import_tasks: "edctl.yml",
    tags: "jbuild_edctl",
    delegate_to: V.jbuild_edctl_host,
  },
  {
    import_tasks: "jyctl.yml",
    tags: "jbuild_jyctl",
    delegate_to: V.jbuild_jyctl_host,
  },
  {
    import_tasks: "rsync.yml",
    tags: "jbuild_rsync",
    delegate_to: V.jbuild_rsync_host,
  },
] satisfies TaskFile;
