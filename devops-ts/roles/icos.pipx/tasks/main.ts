import { pipx_home, pipx_upgrade } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { iff, tmpl } from "../../../lib/template.ts";

// Install pipx using ansible's python. This will allow us to use the ansible
// pipx module to install utils written in python.
export default [
  {
    name: "Install pipx",
    pip: {
      name: "pipx",
      virtualenv: tmpl`${pipx_home}/.venv`,
      state: iff(pipx_upgrade, "latest", "present"),
    },
  },
  {
    name: "Create pipx cli wrapper",
    copy: {
      dest: "/usr/local/bin/pipx",
      mode: "+x",
      content: `#!/usr/bin/bash
{{ pipx_home }}/.venv/bin/pipx "$@"
`,
    },
  },
  {
    name: 'Create "global" version of pipx cli wrapper',
    copy: {
      dest: "/usr/local/sbin/pipx-global",
      mode: "+x",
      content: `#!/usr/bin/bash
PIPX_HOME={{ pipx_home }} PIPX_BIN_DIR=/usr/local/bin {{ pipx_home }}/.venv/bin/pipx "$@"
`,
    },
  },
] satisfies TaskFile;
