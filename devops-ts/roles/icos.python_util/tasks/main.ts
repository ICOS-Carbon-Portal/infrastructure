import {
  python_util_install_dir,
  python_util_install_prefix,
  python_util_python_executable,
} from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { python_util_src } from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { eq } from "../../../lib/vars.ts";

const _pipx = register("_pipx");

export default [
  {
    name: "Copying python utility",
    copy: {
      src: python_util_src,
      dest: python_util_install_prefix,
    },
    register: "_util",
  },
  {
    name: "Installing python utility",
    "community.general.pipx": {
      executable: "pipx-global",
      python: python_util_python_executable,
      editable: true,
      // name can be a pypi name or - in this case - a filesystem path
      name: python_util_install_dir,
    },
    register: _pipx,
    // pipx seems to always report changed when installing editable from file
    changed_when: [
      _pipx.changed,
      _pipx.stdout,
      eq(_pipx.stdout.find("already seems to be installed"), -1),
    ],
  },
] satisfies TaskFile;
