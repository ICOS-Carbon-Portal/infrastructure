import {
  isDefined,
  loopOverVar,
  type Playbook,
  tmpl,
  V,
} from "../lib/ansible.ts";

export default [
  // ZFS
  {
    hosts: ["fsicos3"],
    tags: ["zfs"],
    tasks: [
      {
        name: "Create /incoming",
        tags: "incoming",
        zfs: {
          name: "pool/incoming",
          state: "present",
          extra_zfs_properties: {
            mountpoint: "/incoming",
          },
        },
      },
    ],
  },

  // NFS
  {
    hosts: ["fsicos2", "fsicos3", "icos1", "cupcake", "pancake"],
    tags: ["nfs"],
    handlers: [
      {
        name: "Reload NFS server",
        service: {
          name: "nfs-server",
          state: "reloaded",
        },
      },
    ],
    tasks: [
      {
        when: isDefined("icosdata_exports"),
        name: "Install packages",
        apt: {
          name: "nfs-kernel-server",
          state: "present",
        },
      },
      {
        when: isDefined("icosdata_nfs_mounts"),
        name: "Install nfs-client",
        apt: {
          name: ["nfs-client"],
        },
      },
      {
        name: "Create directories",
        file: {
          path: V.item,
          state: "directory",
        },
        loop: V.icosdata_mkdirs.default([]),
      },
      loopOverVar<{ opts: string; path: string; src: string }>(
        V.icosdata_bind_mounts.default([]),
        (item) => ({
          name: "Do bind-mount local data",
          mount: {
            fstype: "none",
            state: "mounted",
            path: item.path,
            src: item.src,
            opts: tmpl`bind${item.opts.default("")}`,
          },
        }),
      ),
      {
        when: isDefined("icosdata_exports"),
        name: "Export data via nfs",
        tags: "export",
        blockinfile: {
          path: "/etc/exports",
          create: true,
          marker: "# {mark} icosdata",
          block: V.icosdata_exports,
        },
        notify: "Reload NFS server",
      },
      {
        when: isDefined("icosdata_exports"),
        name: "Export all directories listed in `/etc/exports`",
        tags: "export",
        command: "exportfs -rav",
        changed_when: false,
      },
      loopOverVar<{ opts: string; path: string; src: string; state: string }>(
        V.icosdata_nfs_mounts,
        (item) => ({
          when: isDefined("icosdata_nfs_mounts"),
          name: "Mount nfs data",
          tags: "mount",
          mount: {
            fstype: "nfs4",
            state: item.state.default("mounted"),
            // The next two default to omit so that they can be left out when state
            // is "unmounted".
            src: item.src.default(V.omit),
            path: item.path.default(V.omit),
            opts: item.opts.default("ro"),
          },
        }),
      ),
    ],
  },

  // LXD
  {
    hosts: "fsicos3",
    tasks: [
      {
        name: "Create icosdata LXD profile",
        tags: "profile",
        lxd_profile: {
          name: "icosdata",
          devices: {
            radonmap: {
              path: "/data/radon_map",
              source: "/pool/ute/radon_map",
              type: "disk",
              readonly: "true",
            },
            stilt: {
              path: "/data/stilt",
              source: "/pool/ute/stilt/RINGO/T1.3/STILT",
              type: "disk",
              readonly: "true",
            },
            fluxcom_upload: {
              path: "/data/fluxcom/pre_release",
              source: "/pool/fluxcom/upload",
              type: "disk",
              readonly: "true",
            },
          },
        },
      },
    ],
  },
] satisfies Playbook;
