import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: tmpl`Remove docker storage volume for ${V.zfsdocker_name}`,
    zfs: {
      name: tmpl`pool/docker/${V.zfsdocker_name}`,
      state: "absent",
    },
  },
] satisfies TaskFile;
