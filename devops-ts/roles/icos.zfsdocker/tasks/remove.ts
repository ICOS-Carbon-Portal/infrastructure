import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: tmpl("Remove docker storage volume for {{ zfsdocker_name }}"),
    zfs: {
      name: tmpl("pool/docker/{{ zfsdocker_name }}"),
      state: "absent",
    },
  },
] satisfies TaskFile;
