import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create victoriametrics directories",
    file: {
      path: "{{ vm_home }}/{{ item }}",
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
      path: "{{ vm_home }}/grafana",
      owner: 472,
      recurse: true,
    },
    changed_when: false,
  },
  {
    name: "Copy files",
    template: {
      src: "{{ item.src }}",
      dest: "{{ vm_home }}/{{ item.dest | default('') }}",
    },
    loop: [
      { src: "docker-compose.yml" },
      {
        src: "grafana.ini",
        dest: "grafana",
      },
    ],
  },
  {
    name: "Create victoriametrics scrape config",
    copy: {
      content: "{{ vm_scrape_conf }}",
      dest: "{{ vm_home }}/victoriametrics/prometheus/prometheus.yml",
    },
  },
  {
    name: "Build and start",
    "community.docker.docker_compose_v2": {
      project_src: "{{ vm_home }}",
      pull: "{{ 'always' if vm_upgrade else omit }}",
    },
  },
  {
    import_tasks: "grafana_datasource.yml",
    tags: "grafana_datasource",
  },
  {
    name: "Check that services responds on local ports",
    uri: {
      url: "http://localhost:{{ item.port }}",
    },
    retries: 10,
    loop_control: {
      label: "{{ item.name }}",
    },
    loop: [
      {
        name: "victoriametrics",
        port: "{{ vm_vm_port }}",
      },
      {
        name: "grafana",
        port: "{{ vm_graf_port }}",
      },
    ],
  },
  {
    import_tasks: "just.yml",
    tags: "victoriametrics_just",
  },
] satisfies TaskFile;
