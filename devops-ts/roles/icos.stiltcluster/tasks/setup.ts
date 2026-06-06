import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";
import { iff } from "../../../lib/template.ts";
import { lt } from "../../../lib/vars.ts";
import { V } from "../_ctx.ts";

const _r = register("_r");

export default [
  {
    name: "Create stiltcluster user",
    user: {
      name: V.stiltcluster_username,
      home: V.stiltcluster_home,
      state: "present",
      shell: "/bin/bash",
      groups: iff(V.stiltcluster_docker, "docker", V.omit),
      append: iff(V.stiltcluster_docker, "yes", V.omit),
    },
  },
  {
    name: "Install jre",
    apt: {
      name: "default-jre-headless",
    },
  },
  {
    name: "Create bin directory",
    file: {
      path: V.stiltcluster_bindir,
      state: "directory",
    },
  },
  {
    name: "Install remove-old-stiltruns timer",
    tags: "stiltcluster_timer",
    include_role: {
      name: "icos.timer",
      apply: {
        tags: "stiltcluster_timer",
      },
    },
    vars: {
      timer_user: "stiltcluster",
      timer_home: "/opt/remove-old-stiltruns",
      timer_name: "remove-old-stiltruns",
      timer_conf: "OnCalendar=daily",
      timer_content: `#!/bin/bash
# Remove old directories from $HOME/.stiltrun
#
# These are created automatically by stilt.py when running stilt simulations. In
# the normal case they're then removed by the stiltweb backend. This script -
# run from cron - is an extra safety to keep $HOME to slowly fill up.

set -u
set -e

cd "$HOME/.stiltruns"

# maxdepth keep it from recursing into directories it's just deleted
# -mtime is the number of days old the directories may be
find . -maxdepth 1 -name 'stilt-run-*' -type d -mtime "+10" -exec rm -rf -- '{}' \\;
`,
    },
  },
  {
    name: "Remove the remove-old-stiltruns cron job",
    cron: {
      name: "remove old stiltruns",
      state: "absent",
    },
    register: _r,
    failed_when: [
      _r.failed,
      lt(_r.msg.find('required executable "crontab"'), 0),
    ],
  },
] satisfies TaskFile;
