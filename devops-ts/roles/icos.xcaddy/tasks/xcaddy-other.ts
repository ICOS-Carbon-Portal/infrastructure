import { iff, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Install xcaddy",
    command: "go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest",
    args: {
      creates: iff(V.xcaddy_upgrade, V.omit, "/opt/xcaddy"),
    },
    environment: {
      GOPATH: "/opt/xcaddy",
    },
  },
  {
    name: "Create /usr/local/bin/xcaddy symlink",
    file: {
      dest: "/usr/local/bin/xcaddy",
      src: "/opt/xcaddy/bin/xcaddy",
      state: "link",
    },
  },
] satisfies TaskFile;
