import { type TaskFile } from "../../../lib/ansible/play.ts";
import {
  jbuild_edctl_host,
  jbuild_jyctl_host,
  jbuild_rsync_host,
} from "../../../lib/paramvars.ts";

export default [
  { import_tasks: "jbuild.yml", tags: "jbuild_jbuild" },
  { import_tasks: "users.yml", tags: "jbuild_users" },
  {
    import_tasks: "edctl.yml",
    tags: "jbuild_edctl",
    delegate_to: jbuild_edctl_host,
  },
  {
    import_tasks: "jyctl.yml",
    tags: "jbuild_jyctl",
    delegate_to: jbuild_jyctl_host,
  },
  {
    import_tasks: "rsync.yml",
    tags: "jbuild_rsync",
    delegate_to: jbuild_rsync_host,
  },
] satisfies TaskFile;
