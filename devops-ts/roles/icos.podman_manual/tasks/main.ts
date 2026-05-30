import { or, raw, type TaskFile } from "../../../lib/ansible.ts";

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
    register: "_podman",
  },
  {
    name: "Installing podman",
    import_tasks: "install.yml",
    tags: "podman_install",
    when: raw("not _podman.stdout.endswith(podman_version)"),
  },
  {
    name: "Podman is installed and the correct version.",
    // _podman will be undefined if we use the podman_configure tag
    when: or(
      raw("_podman is undefined"),
      raw("_podman.stdout.endswith(podman_version)"),
    ),
    block: [
      {
        debug: { msg: "The correct version of podman is installed." },
        when: raw("_podman is undefined"),
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
    when: raw("podman_docker"),
    tags: "podman_docker",
    import_tasks: "docker.yml",
  },
  {
    import_role: { name: "icos.docker_utils" },
    tags: "podman_utils",
  },
] satisfies TaskFile;
