import { iff, raw, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Make sure docker is upgraded if requested",
    when: raw("docker_upgrade | bool"),
    dpkg_selections: {
      name: V.item,
      selection: "install",
    },
    loop: ["docker.io", "containerd"],
  },
  {
    name: "Install/upgrade docker",
    apt: {
      name: ["docker.io", "containerd"],
      state: iff(raw("docker_upgrade | bool"), "latest", "present"),
      update_cache: true,
    },
  },
  {
    name: "Make sure docker isn't upgraded",
    dpkg_selections: {
      name: V.item,
      selection: iff(V.docker_prevent_upgrade, "hold", "install"),
    },
    loop: ["docker.io", "containerd"],
  },
  {
    name: "Install docker-compose",
    pip: { name: "docker-compose" },
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
    name: "Start docker",
    systemd: {
      name: "docker",
      state: "started",
      enabled: true,
    },
  },
  {
    import_tasks: "cleanup.yml",
    tags: "docker_cleanup",
    when: raw("docker_periodic_cleanup"),
  },
  { import_role: "name=icos.docker_utils", tags: "docker_utils" },
] satisfies TaskFile;
