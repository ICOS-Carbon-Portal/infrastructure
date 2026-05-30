import { raw, type TaskFile, type When } from "../../../lib/ansible.ts";

export default [
  {
    name: "Block podman from being apt-installed",
    copy: {
      dest: "/etc/apt/preferences.d/podman",
      content: `Package: podman
Pin: release *
Pin-Priority: -1
`,
    },
  },
  {
    name: "Synchronize configuration files to /etc/containers",
    "ansible.posix.synchronize": {
      src: "containers",
      dest: "/etc/",
      // required to set the owner/group to root
      owner: false,
      group: false,
    },
  },
  {
    name: "Setup bash completion for podman",
    command: "podman completion -f /etc/bash_completion.d/podman bash",
    args: { creates: "/etc/bash_completion.d/podman" },
  },
  {
    name: "Configure storage for LXD + ZFS",
    import_tasks: "zfs-and-lxd.yml",
    when: [raw("icos.inside_lxd"), raw("icos.root_is_zfs")] as unknown as When,
  },
] satisfies TaskFile;
