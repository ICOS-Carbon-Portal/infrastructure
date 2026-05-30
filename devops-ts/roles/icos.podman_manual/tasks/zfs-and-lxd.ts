import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Install fuse-overlayfs",
    apt: { name: ["fuse-overlayfs"] },
  },
  {
    name: "Configure storage.conf",
    copy: {
      dest: "/etc/containers/storage.conf",
      content: `[storage]
driver = "overlay"
graphroot = "/var/lib/containers/storage"
`,
    },
  },
] satisfies TaskFile;
