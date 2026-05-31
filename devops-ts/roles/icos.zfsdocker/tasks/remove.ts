import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    name: tmpl`Remove docker storage volume for ${expr("zfsdocker_name")}`,
    zfs: {
      name: tmpl`pool/docker/${expr("zfsdocker_name")}`,
      state: "absent",
    },
  },
] satisfies TaskFile;
