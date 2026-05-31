import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: "Add docker key",
    "ansible.builtin.get_url": {
      url: "https://download.docker.com/linux/ubuntu/gpg",
      dest: "/etc/apt/trusted.gpg.d/docker.asc",
      mode: "0644",
      force: true,
    },
    register: "_key",
  },
  {
    name: "Retrieve deb_arch fact",
    shellfact: {
      exec: "dpkg --print-architecture",
      fact: "deb_arch",
    },
    check_mode: false,
  },
  {
    name: "Add docker apt repository",
    apt_repository: {
      filename: "docker",
      repo: tmpl(
        "deb [arch={{ deb_arch }} signed-by={{ _key.dest }}] https://download.docker.com/linux/ubuntu {{ ansible_lsb.codename }} stable",
      ),
    },
  },
] satisfies TaskFile;
