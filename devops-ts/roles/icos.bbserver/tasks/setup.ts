import { type TaskFile } from "../../../lib/ansible.ts";
import { expr, tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create bbserver user",
    user: {
      name: V.bbserver_user,
      home: expr("bbserver_home | default(omit)"),
      create_home: true,
      shell: "/usr/bin/bash",
    },
  },
  {
    name: "Change access rights on bbserver_home",
    file: { path: V.bbserver_home, mode: 0o700 },
  },
  {
    name: "Create repo directory",
    file: {
      path: V.bbserver_repo_home,
      state: "directory",
      owner: V.bbserver_user,
      group: V.bbserver_user,
    },
  },
  {
    name: "Install borg-compact timer",
    include_role: {
      name: "icos.timer",
      apply: { tags: "bbserver_compact" },
    },
    vars: {
      timer_user: V.bbserver_user,
      timer_home: tmpl`${V.bbserver_home}/bbserver-compact`,
      timer_name: "bbserver-compact",
      timer_conf: `OnCalendar=weekly
RandomizedDelaySec=3h
`,
      timer_envs: [
        "BORG_RELOCATED_REPO_ACCESS_IS_OK=yes",
        "BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes",
      ],
      timer_content: `#!/bin/bash
# Since borg 1.2, it's not enough to prune repos, they have to be
# compacted as well.
set -eux

cd $HOME/repos
for repo in *.repo; do
  time borg compact --verbose $repo
done
`,
    },
    tags: "bbserver_compact",
  },
] satisfies TaskFile;
