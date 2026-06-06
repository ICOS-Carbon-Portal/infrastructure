import { type TaskFile } from "../../../lib/ansible/play.ts";
import { zfsdocker_name } from "../../../lib/sharedvars.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: tmpl`Remove docker storage volume for ${zfsdocker_name}`,
    zfs: {
      name: tmpl`pool/docker/${zfsdocker_name}`,
      state: "absent",
    },
  },
] satisfies TaskFile;
