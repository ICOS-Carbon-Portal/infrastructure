import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  // FIXME: Remove in 2024
  {
    name: "Remove backup from crontab",
    cron: {
      state: "absent",
      name: "cpmeta_backup",
    },
  },
  // FIXME: Remove in 2024
  {
    name: "Remove old backup script",
    file: {
      path: tmpl`${V.cpmeta_home}/backup.sh`,
      state: "absent",
    },
  },
  {
    include_role: {
      name: "icos.bbclient2",
      public: true,
    },
    vars: {
      bbclient_name: V.cpmeta_bbclient_name,
      bbclient_home: tmpl`${V.cpmeta_home}/.bbclient`,
      bbclient_timer_conf: `OnCalendar=hourly
RandomizedDelaySec=10m
`,
      bbclient_timer_content: `#!/bin/bash
set -xEeo pipefail
cd "{{ cpmeta_home }}"

export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes

{{ bbclient_all }} create -xvs "::{now}" "{{ cpmeta_filestorage_target }}" submitters.conf
{{ bbclient_all }} prune -vs --keep-within 7d --keep-daily=30 --keep-weekly=50
{{ bbclient_all }} compact --verbose
`,
    },
  },
] satisfies TaskFile;
