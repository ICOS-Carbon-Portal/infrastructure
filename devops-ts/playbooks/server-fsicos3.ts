// icos play fsicos3 nginx_certbot
import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";
import { ansible_check_mode } from "../lib/builtins.ts";
import { not } from "../lib/vars.ts";

export default [
  {
    hosts: "fsicos3",
    roles: [
      role("icos.server").tags("server").when(not(ansible_check_mode)),
      role("icos.lxd_server").tags("lxd"),
      role("icos.nginx").tags("nginx"),
      role("icos.podman").tags("podman"),
      role("ops.zfs").tags("zfs"),
    ],
  },
] satisfies Playbook;
