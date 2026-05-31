import { loopOver, type TaskFile, type Tmpl } from "../../../lib/ansible.ts";
import { expr, tmpl } from "../_ctx.ts";

export default [
  {
    name: "Add dokku key",
    "ansible.builtin.get_url": {
      url: "https://packagecloud.io/dokku/dokku/gpgkey",
      dest: "/etc/apt/trusted.gpg.d/dokku.asc",
      mode: "0644",
      force: true,
    },
    register: "_key",
  },
  {
    name: "Add dokku apt repository",
    apt_repository: {
      filename: "dokku",
      repo: tmpl`deb [signed-by=${
        expr("_key.dest")
      }] https://packagecloud.io/dokku/dokku/${
        expr("ansible_lsb.id | lower")
      }/ ${expr("ansible_lsb.codename")} main`,
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
