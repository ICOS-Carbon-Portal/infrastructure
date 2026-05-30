import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Add xcaddy key",
    "ansible.builtin.get_url": {
      url: "https://dl.cloudsmith.io/public/caddy/xcaddy/gpg.key",
      dest: "/etc/apt/trusted.gpg.d/xcaddy.asc",
      mode: "0644",
      force: true,
    },
    register: "_key",
  },
  {
    name: "Add xcaddy apt repository",
    apt_repository: {
      filename: "xcaddy",
      repo:
        "deb [signed-by={{ _key.dest }}] https://dl.cloudsmith.io/public/caddy/xcaddy/deb/debian any-version main",
    },
  },
  {
    name: "Install xcaddy",
    apt: {
      name: "xcaddy",
      state: "{{ 'latest' if xcaddy_upgrade else 'present' }}",
    },
  },
  {
    name: "Test that xcaddy works",
    shell: "xcaddy version",
    changed_when: false,
  },
] satisfies TaskFile;
