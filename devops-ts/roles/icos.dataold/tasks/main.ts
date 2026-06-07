import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    import_role: { name: "icos.certbot2" },
  },
  {
    name: "Create dataold home directory",
    file: {
      path: V.dataold_home,
      state: "directory",
    },
  },
  {
    name: "Copy templates",
    template: {
      src: item,
      dest: V.dataold_home,
      lstrip_blocks: true,
    },
    loop: ["docker-compose.yml", "dataold.conf"],
  },
  {
    name: "Copy files",
    copy: {
      src: item,
      dest: V.dataold_home,
    },
    loop: ["openssl.cnf"],
  },
  {
    name: "Start dataold",
    "community.docker.docker_compose_v2": {
      project_src: V.dataold_home,
    },
  },
  {
    name: tmpl`Open firewall for port ${V.dataold_ext_port}`,
    iptables_raw: {
      name: tmpl`allow_${V.dataold_ext_port}`,
      rules:
        tmpl`-A INPUT -p tcp --dport ${V.dataold_ext_port} -j ACCEPT -m comment --comment 'dataold'`,
    },
  },
] satisfies TaskFile;
