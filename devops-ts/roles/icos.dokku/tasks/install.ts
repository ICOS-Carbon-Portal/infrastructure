import { type TaskFile } from "../../../lib/ansible/play.ts";
import { ansible_lsb } from "../../../lib/builtins.ts";
import { loopOver } from "../../../lib/loop.ts";
import { register } from "../../../lib/register.ts";
import { type Tmpl, tmpl } from "../../../lib/template.ts";

const _key = register("_key");

export default [
  {
    name: "Add dokku key",
    "ansible.builtin.get_url": {
      url: "https://packagecloud.io/dokku/dokku/gpgkey",
      dest: "/etc/apt/trusted.gpg.d/dokku.asc",
      mode: "0644",
      force: true,
    },
    register: _key,
  },
  {
    name: "Add dokku apt repository",
    apt_repository: {
      filename: "dokku",
      repo:
        tmpl`deb [signed-by=${_key.dest.ref}] https://packagecloud.io/dokku/dokku/${ansible_lsb.id.lower()}/ ${ansible_lsb.codename} main`,
    },
  },
  loopOver<{ question: Tmpl; value: Tmpl; vtype: Tmpl }>(
    [
      { question: "dokku/vhost_enable", value: "true", vtype: "boolean" },
      {
        question: "dokku/hostname",
        value: "dokku.fsicos3.icos-cp.eu",
        vtype: "string",
      },
      { question: "dokku/nginx_enable", value: "true", vtype: "boolean" },
    ],
    (item) => ({
      name: "Set debconf values for dokku",
      "ansible.builtin.debconf": {
        name: "dokku",
        question: item.question,
        value: item.value,
        vtype: item.vtype,
      },
    }),
  ),
  {
    name: "Install dokku",
    apt: {
      name: ["dokku"],
    },
  },
] satisfies TaskFile;
