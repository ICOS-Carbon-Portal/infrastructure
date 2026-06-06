import { type TaskFile } from "../../../lib/ansible/play.ts";
import { ansible_lsb } from "../../../lib/builtins.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";

const _key = register("_key");

// https://zrepl.github.io/installation/apt-repos.html

export default [
  {
    name: "Add zrepl key",
    "ansible.builtin.get_url": {
      url: "https://zrepl.cschwarz.com/apt/apt-key.asc",
      dest: "/etc/apt/trusted.gpg.d/zrepl.asc",
      // dest: /usr/share/keyrings/syncthing-archive-keyring.gpg
      mode: "0644",
      force: true,
    },
    register: _key,
  },
  {
    name: "Add zrepl apt repository",
    apt_repository: {
      filename: "zrepl",
      repo:
        tmpl`deb [arch=amd64 signed-by=${_key.dest.ref}] https://zrepl.cschwarz.com/apt/${ansible_lsb.id.lower()} ${ansible_lsb.codename} main`,
    },
  },
  {
    name: "Install zrepl",
    apt: { name: "zrepl" },
  },
  {
    name: "Set permissions on /etc/zrepl",
    file: {
      path: "/etc/zrepl",
      state: "directory",
      mode: "0700",
    },
  },
] satisfies TaskFile;
