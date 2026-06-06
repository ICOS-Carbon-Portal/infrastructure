import { type TaskFile } from "../../../lib/ansible/play.ts";
import { eq, ne } from "../../../lib/vars.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  // First install pip and venv for the system version of python. This is for the
  // sake of later ansible modules.
  {
    name: "Install pip and venv",
    apt: {
      // This role is included by icos.*_guest, and as such is often the first to
      // run on a system.
      update_cache: true,
      cache_valid_time: 86400,
      name: [
        "python3-pip",
        "python3-virtualenv",
        "python3-venv",
      ],
    },
  },
  // On Ubuntu we'll install extra versions of python from here.
  {
    when: eq(V.ansible_distribution, "Ubuntu"),
    name: "Add ppa:deadsnakes repository",
    apt_repository: {
      repo: "ppa:deadsnakes/ppa",
    },
  },
  // Any versions that doesn't match the built-in version
  {
    name: "Install extra version of python",
    apt: {
      name: tmpl`python${V._version}-venv`,
    },
    when: ne(V._builtin_version, V._version),
    loop: V.python3_version_list,
    loop_control: {
      loop_var: "_version",
    },
    vars: {
      _builtin_version:
        tmpl`${V.ansible_python.version.major}.${V.ansible_python.version.minor}`,
    },
  },
] satisfies TaskFile;
