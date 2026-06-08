// Create the ICOS Cities VM.

import { playbook } from "../lib/ansible/playbook.ts";
import { role } from "../lib/ansible/role.ts";
import { item } from "../lib/builtins.ts";
import { cities_datafast_path } from "../lib/globals.ts";
import {
  data_fast_path,
  data_path,
  docker_path,
  pool_name,
  pool_path,
} from "../lib/paramvars.ts";
import { tmpl } from "../lib/vars.ts";

export default playbook(import.meta, [
  {
    hosts: "fsicos2",
    vars: {
      pool_name: "cities",
      pool_path: "/disk/data/lxd/storage_pools/cities",
      data_path: "/disk/data/cities",
      docker_path: "/disk/cities_docker",
      data_fast_path: "/disk/cities_data_fast",
    },
    pre_tasks: [
      {
        name: "Create cities storage_pool directory",
        file: {
          path: pool_path,
          state: "directory",
        },
      },
      {
        name: "Create cities directories",
        file: {
          path: item,
          state: "directory",
          owner: 1000000,
          group: 1000000,
        },
        loop: [
          data_path,
          docker_path,
          data_fast_path,
        ],
      },
      {
        name: "Create cities storage pool",
        shell:
          tmpl`/snap/bin/lxc storage show ${pool_name} > /dev/null 2>&1 || \\ /snap/bin/lxc storage create ${pool_name} dir source="${pool_path}"
`,
        register: "_r",
        changed_when: ['("Storage pool %s created" % pool_name) in _r.stdout'],
      },
    ],
    roles: [
      role("icos.lxd_vm", {
        name: "Create the cities VM",
        vars: {
          lxd_vm_name: "cities",
          lxd_vm_ubuntu_version: "20.04",
          lxd_vm_root_pool: "cities",
          lxd_vm_config: {
            "security.nesting": "true",
            "limits.cpu": "16",
            "limits.memory": "64GB",
          },
          lxd_vm_devices: {
            data: {
              path: "/data",
              source: data_path,
              type: "disk",
            },
            data_fast: {
              path: cities_datafast_path,
              source: data_fast_path,
              type: "disk",
            },
            docker: {
              path: "/var/lib/docker",
              source: docker_path,
              type: "disk",
            },
          },
        },
      }),
    ],
  },
  {
    hosts: "cities",
    roles: [
      role("icos.lxd_guest").tags("guest"),

      role("icos.docker2").tags("docker"),
    ],
    tasks: [
      {
        name: "Check /data for write access",
        shell: `rm -- $(mktemp -p /data)
`,
        changed_when: false,
      },
    ],
  },
]);
