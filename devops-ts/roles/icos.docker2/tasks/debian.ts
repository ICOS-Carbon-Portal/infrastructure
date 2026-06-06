import { type TaskFile } from "../../../lib/ansible/play.ts";
import { ansible_lsb } from "../../../lib/builtins.ts";
import { deb_arch } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";

const _key = register("_key");

export default [
  {
    name: "Add docker key",
    "ansible.builtin.get_url": {
      url: "https://download.docker.com/linux/debian/gpg",
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
  },
  {
    name: "Add docker apt repository",
    apt_repository: {
      filename: "docker",
      repo:
        tmpl`deb [arch=${deb_arch} signed-by=${_key.dest.ref}] https://download.docker.com/linux/debian ${ansible_lsb.codename} stable`,
    },
  },
] satisfies TaskFile;
