import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create pgrep directories",
    file: {
      path: tmpl`${V.pgrep_home}/volumes`,
      state: "directory",
      mode: "0700",
    },
  },
  {
    name: "Install peer certificate",
    copy: {
      src: V.pgrep_peer_cert,
      dest: tmpl`${V.pgrep_home}/peer.crt`,
    },
  },
  {
    name: "Install runtime files",
    template: {
      src: "{{ item.src }}",
      dest: V.pgrep_home,
      mode: "{{ item.mode | default(omit) }}",
    },
    loop: [
      { src: "docker-compose.yml" },
      { src: "pgpass" },
      { src: "status.sql" },
      { src: "queries.yml" },
      { src: "entrypoint.sh", mode: "+x" },
      { src: "psql", mode: "+x" },
      { src: "psql-peer", mode: "+x" },
    ],
  },
  {
    name: "Start containers",
    "community.docker.docker_compose_v2": {
      project_src: V.pgrep_home,
    },
  },
  {
    name: "Check that psql wrappers works",
    shell: tmpl`${V.pgrep_home}/${V.item} -c 'select version()'\n`,
    changed_when: false,
    register: "_r",
    failed_when: [
      "not 'PostgreSQL' in _r.stdout",
    ],
    loop: [
      "psql",
      "psql-peer", // requires peer to be online
    ],
  },
] satisfies TaskFile;
