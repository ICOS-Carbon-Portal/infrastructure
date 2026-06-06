import { xcaddy_upgrade } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { iff, tmpl } from "../../../lib/template.ts";

const _key = register("_key");

export default [
  {
    name: "Add xcaddy key",
    "ansible.builtin.get_url": {
      url: "https://dl.cloudsmith.io/public/caddy/xcaddy/gpg.key",
      dest: "/etc/apt/trusted.gpg.d/xcaddy.asc",
      mode: "0644",
      force: true,
    },
    register: _key,
  },
  {
    name: "Add xcaddy apt repository",
    apt_repository: {
      filename: "xcaddy",
      repo:
        tmpl`deb [signed-by=${_key.dest.ref}] https://dl.cloudsmith.io/public/caddy/xcaddy/deb/debian any-version main`,
    },
  },
  {
    name: "Install xcaddy",
    apt: {
      name: "xcaddy",
      state: iff(xcaddy_upgrade, "latest", "present"),
    },
  },
  {
    name: "Test that xcaddy works",
    shell: "xcaddy version",
    changed_when: false,
  },
] satisfies TaskFile;
