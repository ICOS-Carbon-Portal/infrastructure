import { type Playbook, role } from "../lib/ansible.ts";

export default [
  {
    hosts: "staging_server",
    pre_tasks: [
      {
        name: "Create  directory",
        tags: "vm",
        file: {
          path: "/disk/data/staging",
          state: "directory",
          owner: 1000000,
          group: 1000000,
        },
      },
    ],
    roles: [
      role("icos.lxd_vm", {
        lxd_vm_name: "staging",
        lxd_vm_docker: true,
        lxd_vm_root_size: "200GB",
        lxd_vm_devices: {
          dataprod: {
            path: "/data/dataAppStorage/",
            source: "/disk/data/dataAppStorage/",
            type: "disk",
            readonly: "true",
          },
          staging: {
            path: "/data/staging",
            source: "/disk/data/staging",
            type: "disk",
          },
        },
      }).tags("vm"),
    ],
  },
  {
    hosts: "staging",
    roles: [
      role("icos.lxd_guest").tags("guest"),
      role("icos.docker").tags("docker"),
      role("icos.restheart").tags("restheart"),
    ],
  },
] satisfies Playbook;
