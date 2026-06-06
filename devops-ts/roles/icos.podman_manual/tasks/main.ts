import { podman_docker, podman_version } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { isUndefined, not, or, truthy } from "../../../lib/vars.ts";

const _podman = register("_podman");

export default [
  {
    name: "Check whether podman is dpkg-installed",
    command: "dpkg -s podman",
    failed_when: false,
    changed_when: false,
    register: "_dpkg",
  },
  {
    name: "Fail if podman is apt-installed",
    "ansible.builtin.shell":
      `dpkg --get-selections podman | grep -vq '\\binstall'
`,
    changed_when: false,
    register: "r",
    failed_when: "r.rc == 0",
  },
  {
    name: "Checking for version of installed podman",
    check_mode: false,
    command: "podman --version",
    failed_when: false,
    changed_when: false,
    register: _podman,
  },
  {
    name: "Installing podman",
    import_tasks: "install.yml",
    tags: "podman_install",
    when: not(_podman.stdout.endswith(podman_version)),
  },
  {
    name: "Podman is installed and the correct version.",
    // _podman will be undefined if we use the podman_configure tag
    when: or(
      isUndefined(_podman.ref),
      _podman.stdout.endswith(podman_version),
    ),
    block: [
      {
        debug: { msg: "The correct version of podman is installed." },
        when: isUndefined(_podman.ref),
      },
      {
        import_tasks: "configure.yml",
        tags: "podman_configure",
      },
    ],
  },
  {
    name: "Install conmon",
    tags: "podman_conmon",
    import_role: { name: "icos.conmon" },
  },
  {
    name: "Install cni_plugins",
    tags: "podman_cni_plugins",
    import_role: { name: "icos.cni_plugins" },
  },
  {
    name: "Install containers-storage",
    apt: { name: "containers-storage" },
  },
  {
    name: "Emulate docker",
    when: truthy(podman_docker),
    tags: "podman_docker",
    import_tasks: "docker.yml",
  },
  {
    import_role: { name: "icos.docker_utils" },
    tags: "podman_utils",
  },
] satisfies TaskFile;
