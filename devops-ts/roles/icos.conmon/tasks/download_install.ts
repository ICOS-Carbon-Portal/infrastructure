import { conmon_url, conmon_version_install } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";

const _download = register("_download");

export default [
  // Never overwrite apt-installed conmon with downloaded version.
  {
    name: "Fail if conmon is apt-installed",
    "ansible.builtin.shell":
      `dpkg --get-selections conmon | grep -vq '\\binstall'
`,
    changed_when: false,
    register: "r",
    failed_when: "r.rc == 0",
  },
  {
    name: "Install packages needed to compile conmon",
    apt: {
      name: [
        "gcc",
        "git",
        "libc6-dev",
        "libglib2.0-dev",
        "libseccomp-dev",
        "pkg-config",
        "make",
        "crun",
      ],
    },
  },
  {
    name: "Download conmon sources",
    get_url: {
      url: conmon_url,
      dest: "/tmp",
    },
    register: _download,
  },
  {
    name: "Unarchive sources",
    unarchive: {
      src: _download.dest.ref,
      dest: "/tmp",
      remote_src: true,
    },
    diff: false,
  },
  {
    name: "Build conmon",
    make: {
      chdir: tmpl`/tmp/conmon-${conmon_version_install}`,
      target: "podman",
    },
  },
] satisfies TaskFile;
