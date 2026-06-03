// Create the ICOS Cities VM.

import { type Playbook, rawTmpl, role, tmpl, V } from "../lib/ansible.ts";

export default [
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
          path: V.pool_path,
          state: "directory",
        },
      },
      {
        name: "Create cities directories",
        file: {
          path: V.item,
          state: "directory",
          owner: 1000000,
          group: 1000000,
        },
        loop: [
          V.data_path,
          V.docker_path,
          V.data_fast_path,
        ],
      },
      {
        name: "Create cities storage pool",
        shell:
          tmpl`/snap/bin/lxc storage show ${V.pool_name} > /dev/null 2>&1 || \\ /snap/bin/lxc storage create ${V.pool_name} dir source="${
            rawTmpl("{{ pool_path}}")
          }"
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
              source: V.data_path,
              type: "disk",
            },
            data_fast: {
              path: V.cities_datafast_path,
              source: V.data_fast_path,
              type: "disk",
            },
            docker: {
              path: "/var/lib/docker",
              source: V.docker_path,
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
] satisfies Playbook;
