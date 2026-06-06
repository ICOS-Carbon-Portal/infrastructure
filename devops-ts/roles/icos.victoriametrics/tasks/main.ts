import {
  vm_graf_port,
  vm_home,
  vm_scrape_conf,
  vm_upgrade,
  vm_vm_port,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item, omit } from "../../../lib/builtins.ts";
import { loopOver } from "../../../lib/loop.ts";
import { iff, type Tmpl, tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Create victoriametrics directories",
    file: {
      path: tmpl`${vm_home}/${item}`,
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
      path: tmpl`${vm_home}/grafana`,
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
        dest: tmpl`${vm_home}/${item.dest.default("")}`,
      },
    }),
  ),
  {
    name: "Create victoriametrics scrape config",
    copy: {
      content: vm_scrape_conf,
      dest: tmpl`${vm_home}/victoriametrics/prometheus/prometheus.yml`,
    },
  },
  {
    name: "Build and start",
    "community.docker.docker_compose_v2": {
      project_src: vm_home,
      pull: iff(vm_upgrade, "always", omit),
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
        port: vm_vm_port,
      },
      {
        name: "grafana",
        port: vm_graf_port,
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
