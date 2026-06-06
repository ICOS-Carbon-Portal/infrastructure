import { xcaddy_upgrade } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { omit } from "../../../lib/builtins.ts";
import { iff } from "../../../lib/template.ts";

export default [
  {
    name: "Install xcaddy",
    command: "go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest",
    args: {
      creates: iff(xcaddy_upgrade, omit, "/opt/xcaddy"),
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
