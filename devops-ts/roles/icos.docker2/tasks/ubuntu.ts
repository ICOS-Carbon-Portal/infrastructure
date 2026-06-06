import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { tmpl, V } from "../_ctx.ts";

const _key = register("_key");

export default [
  {
    name: "Add docker key",
    "ansible.builtin.get_url": {
      url: "https://download.docker.com/linux/ubuntu/gpg",
      dest: "/etc/apt/trusted.gpg.d/docker.asc",
      mode: "0644",
      force: true,
    },
    register: _key,
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
      repo:
        tmpl`deb [arch=${V.deb_arch} signed-by=${_key.dest.ref}] https://download.docker.com/linux/ubuntu ${V.ansible_lsb.codename} stable`,
    },
  },
] satisfies TaskFile;
