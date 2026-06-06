import { type Playbook } from "../lib/ansible/play.ts";
import { role } from "../lib/ansible/role.ts";

export default [
  {
    hosts: "fsicos2",
    tasks: [
      {
        name: "Retrive stiltcluster.jar",
        fetch: {
          src: "/home/stiltcluster/stiltcluster.jar",
          // the destination is relative to the playbook
          dest: "tmp/stiltcluster.jar",
          // don't append hostname/path/to/file
          flat: true,
        },
      },
    ],
  },
  {
    hosts: "fsicos4-stiltcluster",
    roles: [
      role("icos.pve_guest").tags("guest"),
      role("icos.python3").tags("python3"),
      role("icos.docker2").tags("docker"),
      role("icos.stiltrun").tags("stiltrun"),
      role("icos.stiltcluster").tags("stiltcluster"),
    ],
  },
] satisfies Playbook;
