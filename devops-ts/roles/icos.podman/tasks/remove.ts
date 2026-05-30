import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Uninstall podman",
    apt: {
      state: "absent",
      name: [
        "podman",
        "podman-plugins",
        "netavark",
        "containernetworking-plugins",
      ],
    },
  },
  {
    name: "Remove kubic key",
    file: {
      name: "/etc/apt/trusted.gpg.d/kubic.asc",
      state: "absent",
    },
  },
] satisfies TaskFile;
