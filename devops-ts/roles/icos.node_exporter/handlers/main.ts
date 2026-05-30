import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  // node-exporter is socket activated, so restart the socket
  {
    name: "restart node-exporter",
    systemd: {
      name: "node-exporter.socket",
      state: "restarted",
    },
  },
] satisfies TaskFile;
