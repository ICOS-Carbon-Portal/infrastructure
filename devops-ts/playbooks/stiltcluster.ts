// This playbook depends on:
//  Each host having been installed with docker etc.
//  Each host being part of the nebula network.

import { expr, isDefined, type Playbook, role, tmpl } from "../lib/ansible.ts";

export default [
  {
    hosts: "fsicos2",
    handlers: [
      {
        name: "reload nfs server",
        service: {
          name: "nfs-server",
          state: "reloaded",
        },
      },
    ],
    tasks: [
      {
        name: "Export stilt input data",
        tags: "inputdata",
        blockinfile: {
          marker: "# {mark} stiltcluster",
          create: true,
          path: "/etc/exports",
          block: `/disk/data/stilt            *.nebula(ro,no_root_squash)
`,
        },
        notify: "reload nfs server",
      },
    ],
  },
  {
    hosts: "stiltcluster_hosts",
    pre_tasks: [
      // Some hosts already have the stilt input data present
      {
        when: isDefined("stilt_input_mount").default(false),
        tags: "inputdata",
        block: [
          {
            name: "Create stilt input dir",
            file: {
              path: expr("stilt_input_dir"),
              state: "directory",
            },
          },
          {
            name: "Mount stilt input data",
            mount: {
              src: "fsicos2.nebula:/disk/data/stilt/Input",
              path: expr("stilt_input_dir"),
              state: "mounted",
              fstype: "nfs4",
            },
          },
        ],
      },
    ],
    roles: [
      role("icos.stiltrun").tags("stiltrun"),
      role("icos.stiltcluster").tags("stiltcluster"),
    ],
  },
] satisfies Playbook;
