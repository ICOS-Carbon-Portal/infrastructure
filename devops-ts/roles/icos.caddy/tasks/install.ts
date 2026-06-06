import { type TaskFile } from "../../../lib/ansible/play.ts";
import { iff } from "../../../lib/template.ts";
import { V } from "../_ctx.ts";

// https://caddyserver.com/docs/install#debian-ubuntu-raspbian
export default [
  {
    name: "Add caddy signing key",
    "ansible.builtin.get_url": {
      url: "https://dl.cloudsmith.io/public/caddy/stable/gpg.key",
      dest: "/etc/apt/trusted.gpg.d/caddy.asc",
      mode: "0644",
      force: true,
    },
  },
  {
    name: "Add caddy apt repository",
    apt_repository: {
      filename: "caddy",
      repo:
        "deb [signed-by=/etc/apt/trusted.gpg.d/caddy.asc] https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main",
    },
  },
  {
    name: "Install caddy",
    apt: {
      name: "caddy",
      state: iff(V.caddy_upgrade, "latest", "present"),
    },
    notify: "restart caddy",
  },
  {
    name: "Remove default config file",
    shell: `head -1 Caddyfile | grep -q -F '# The Caddyfile is an easy way' \\
  && mv Caddyfile Caddyfile.dist || :
`,
    args: {
      chdir: "/etc/caddy",
      creates: "/etc/caddy/Caddyfile.dist",
    },
    changed_when: false,
  },
] satisfies TaskFile;
