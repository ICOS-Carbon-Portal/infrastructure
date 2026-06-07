import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  {
    name: "Include vars for zfs",
    include_vars: "zfs.yml",
  },
  {
    name: "Create docker storage for LXD",
    when: truthy(V.lxd_vm_docker),
    import_role: { name: "icos.zfsdocker" },
    vars: { zfsdocker_size: V.lxd_vm_docker_size },
  },
] satisfies TaskFile;
