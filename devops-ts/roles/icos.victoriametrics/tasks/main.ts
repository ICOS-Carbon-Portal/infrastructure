import {
  iff,
  loopOver,
  type TaskFile,
  type Tmpl,
} from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create victoriametrics directories",
    file: {
      path: tmpl`${V.vm_home}/${V.item}`,
      state: "directory",
    },
    loop: [
      "victoriametrics/prometheus",
      "grafana/provisioning",
    ],
  },
  {
    name: "Change owner of grafana directories",
    file: {
      path: tmpl`${V.vm_home}/grafana`,
      owner: 472,
      recurse: true,
    },
    changed_when: false,
  },
  loopOver<{ src: Tmpl; dest?: Tmpl }>(
    [
      { src: "docker-compose.yml" },
      {
        src: "grafana.ini",
        dest: "grafana",
      },
    ],
    (item) => ({
      name: "Copy files",
      template: {
        src: item.src,
        dest: tmpl`${V.vm_home}/${item.dest.default("")}`,
      },
    }),
  ),
  {
    name: "Create victoriametrics scrape config",
    copy: {
      content: V.vm_scrape_conf,
      dest: tmpl`${V.vm_home}/victoriametrics/prometheus/prometheus.yml`,
    },
  },
  {
    name: "Build and start",
    "community.docker.docker_compose_v2": {
      project_src: V.vm_home,
      pull: iff(V.vm_upgrade, "always", V.omit),
    },
  },
  {
    import_tasks: "grafana_datasource.yml",
    tags: "grafana_datasource",
  },
  loopOver<{ name: Tmpl; port: Tmpl }>(
    [
      {
        name: "victoriametrics",
        port: V.vm_vm_port,
      },
      {
        name: "grafana",
        port: V.vm_graf_port,
      },
    ],
    (item) => ({
      name: "Check that services responds on local ports",
      uri: {
        url: tmpl`http://localhost:${item.port}`,
      },
      retries: 10,
      loop_control: {
        label: item.name,
      },
    }),
  ),
  {
    import_tasks: "just.yml",
    tags: "victoriametrics_just",
  },
] satisfies TaskFile;
