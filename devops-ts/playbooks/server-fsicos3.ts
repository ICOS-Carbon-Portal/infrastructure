// icos play fsicos3 nginx_certbot
import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos3",
    roles: [
      // ansible_check_mode is a built-in fact, so this stays a raw expression.
      role("icos.server").tags("server").when("not ansible_check_mode"),
      role("icos.lxd_server").tags("lxd"),
      role("icos.nginx").tags("nginx"),
      role("icos.podman").tags("podman"),
      role("ops.zfs").tags("zfs"),
    ],
  },
] satisfies Playbook;
