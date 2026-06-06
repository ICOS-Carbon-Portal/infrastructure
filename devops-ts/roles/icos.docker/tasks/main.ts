import {
  docker_periodic_cleanup,
  docker_prevent_upgrade,
  docker_upgrade,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { iff } from "../../../lib/template.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  {
    name: "Make sure docker is upgraded if requested",
    when: truthy(docker_upgrade).bool(),
    dpkg_selections: {
      name: item,
      selection: "install",
    },
    loop: ["docker.io", "containerd"],
  },
  {
    name: "Install/upgrade docker",
    apt: {
      name: ["docker.io", "containerd"],
      state: iff(truthy(docker_upgrade).bool(), "latest", "present"),
      update_cache: true,
    },
  },
  {
    name: "Make sure docker isn't upgraded",
    dpkg_selections: {
      name: item,
      selection: iff(docker_prevent_upgrade, "hold", "install"),
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
    when: truthy(docker_periodic_cleanup),
  },
  { import_role: "name=icos.docker_utils", tags: "docker_utils" },
] satisfies TaskFile;
