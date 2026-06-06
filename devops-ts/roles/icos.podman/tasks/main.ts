import { type TaskFile } from "../../../lib/ansible/play.ts";
import { ansible_lsb } from "../../../lib/builtins.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";

const _key = register("_key");

export default [
  {
    name: "Add kubic key",
    "ansible.builtin.get_url": {
      url:
        tmpl`https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_${ansible_lsb.release}/Release.key`,
      dest: "/etc/apt/trusted.gpg.d/kubic.asc",
      mode: "0644",
      force: true,
    },
    register: _key,
  },
  {
    name: "Add kubic apt repository",
    apt_repository: {
      filename: "kubic",
      repo:
        tmpl`deb [signed-by=${_key.dest.ref}] https://download.opensuse.org/repositories/devel:kubic:libcontainers:unstable/xUbuntu_${ansible_lsb.release}/ /
`,
    },
  },
  {
    name: "Install podman",
    apt: {
      update_cache: true,
      name: [
        "podman",
        "podman-plugins",
        //      // The new (podman v4) networking stactk
        //      - netavark
        // This wasn't pulled in automatically and podman failed without it.
        "containernetworking-plugins",
      ],
    },
  },
] satisfies TaskFile;
