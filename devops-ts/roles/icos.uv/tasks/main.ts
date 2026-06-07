import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { ansible_check_mode } from "../../../lib/builtins.ts";
import { register } from "../../../lib/register.ts";
import { not, or, truthy } from "../../../lib/vars.ts";

const _r = register("_r");

export default [
  {
    name: "Check whether uv is installed",
    stat: {
      path: "/usr/local/bin/uv",
    },
    register: _r,
  },
  {
    name: "Install/upgrade uv",
    include_tasks: {
      file: "install.yml",
    },
    when: or(
      not(_r.stat.exists),
      truthy(V.uv_upgrade),
      not(ansible_check_mode),
    ),
  },
  {
    name: 'Create "global" version of uv',
    copy: {
      dest: "/usr/local/sbin/uv-global",
      mode: "+x",
      content: `#!/usr/bin/bash
# This wrapper installs globally available tools using "uv tool"
export UV_TOOL_DIR={{ uv_home }}/tools
export UV_TOOL_BIN_DIR=/usr/local/bin
export UV_CACHE_DIR={{ uv_home }}/cache
export UV_PYTHON_INSTALL_DIR={{ uv_home }}/python
exec /usr/local/bin/uv "$@"
`,
    },
  },
] satisfies TaskFile;
