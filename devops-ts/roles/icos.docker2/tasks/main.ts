import { raw, type TaskFile, truthy } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Fail if docker.io is apt-installed",
    "ansible.builtin.shell":
      `dpkg --get-selections docker.io | grep -vq '\\binstall'
`,
    changed_when: false,
    register: "r",
    failed_when: "r.rc == 0",
  },
  {
    import_tasks: "debian.yml",
    when: raw('ansible_distribution == "Debian"'),
  },
  {
    import_tasks: "ubuntu.yml",
    when: raw('ansible_distribution == "Ubuntu"'),
  },
  {
    name: "Fail if we're not on a supported distribution",
    fail: {
      msg: "This role currently only support Debian and Ubuntu",
    },
    when: raw("ansible_distribution not in ('Debian', 'Ubuntu')"),
  },
  {
    name: "Uninstall docker-compose version 1",
    apt: {
      name: "docker-compose",
      state: "absent",
    },
  },
  {
    name: "Install docker and docker-compose",
    apt: {
      name: [
        "docker-ce",
        "docker-ce-cli",
        "containerd.io",
        "docker-buildx-plugin",
        "docker-compose-plugin",
      ],
    },
  },
  {
    name: "Make sure docker is started",
    systemd: {
      name: "docker",
      state: "started",
      enabled: true,
    },
  },
  {
    name: "Install docker configuration",
    copy: {
      src: "daemon.json",
      dest: "/etc/docker/",
    },
    notify: "reload docker",
  },
  {
    import_tasks: "cleanup.yml",
    tags: "docker_cleanup",
    when: truthy(V.docker_periodic_cleanup),
  },
  {
    import_role: "name=icos.docker_utils",
    tags: "docker_utils",
  },
  { import_tasks: "test.yml", tags: "docker_test" },
  { import_tasks: "just.yml", tags: "docker_just" },
] satisfies TaskFile;
