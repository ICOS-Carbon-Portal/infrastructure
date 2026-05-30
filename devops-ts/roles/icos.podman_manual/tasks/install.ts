import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Install golang",
    import_role: { name: "icos.golang" },
  },
  {
    name: "Install podman requirements",
    apt: {
      name: [
        "btrfs-progs",
        "git",
        "go-md2man",
        "iptables",
        "libassuan-dev",
        "libbtrfs-dev",
        "libc6-dev",
        "libdevmapper-dev",
        "libglib2.0-dev",
        "libgpgme-dev",
        "libgpg-error-dev",
        "libprotobuf-dev",
        "libprotobuf-c-dev",
        "libseccomp-dev",
        "libselinux1-dev",
        "libsystemd-dev",
        "pkg-config",
        // crun is smaller than runc
        "crun",
        "uidmap",
        // slirp4netns is the default network mode for rootless
        // containers. https://github.com/containers/podman/issues/7810
        "slirp4netns",
      ],
    },
  },
  {
    name: "Assert that user namespaces are available",
    check_mode: false,
    command: tmpl`grep -q CONFIG_USER_NS=y /boot/config-${V.ansible_kernel}`,
    args: {
      // When running in LXD, /boot/config-* won't exist and grep will fail.
      // Use "removes" as a way to avoid this check completely.
      removes: tmpl`/boot/config-${V.ansible_kernel}`,
    },
    changed_when: false,
  },
  {
    name: "Clone podman",
    git: {
      repo: "https://github.com/containers/podman",
      version: tmpl`v${V.podman_version}`,
      dest: V.podman_src_dir,
    },
    diff: false,
  },
  {
    name: "Build podman",
    make: {
      chdir: V.podman_src_dir,
      target: "default",
      params: { BUILDTAGS: "seccomp selinux systemd" },
    },
  },
  {
    name: "Install podman",
    make: {
      chdir: V.podman_src_dir,
      target: "install",
    },
  },
] satisfies TaskFile;
