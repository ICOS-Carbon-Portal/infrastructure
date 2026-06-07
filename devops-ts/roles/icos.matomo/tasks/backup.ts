import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    include_role: {
      name: "icos.bbclient2",
      public: true,
    },
    vars: {
      bbclient_name: "matomo",
      bbclient_home: tmpl`${V.matomo_home}/.bbclient`,
      bbclient_timer_content: `#!/bin/bash
set -Eueo pipefail

cd "{{ matomo_home }}"
mkdir -p backup

docker-compose exec -T db mysqldump --extended-insert --no-autocommit --quick --single-transaction matomo -u{{ matomo_mysql_user }} -p{{ matomo_mysql_password }} > backup/matomo.sql

{{ bbclient_all }} create -xvs '::{now}' backup
{{ bbclient_all }} prune -vs --keep-within 7d --keep-daily=30 --keep-weekly=150
{{ bbclient_all }} compact --verbose

rm -rf -- ./backup
`,
    },
  },
] satisfies TaskFile;
