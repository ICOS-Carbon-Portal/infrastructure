import { plausible_home } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    include_role: { name: "icos.bbclient2", public: true },
    vars: {
      bbclient_name: "plausible",
      bbclient_home: tmpl`${plausible_home}/.bbclient`,
      bbclient_timer_content: `#!/bin/bash
set -Eueo pipefail

cd "{{ plausible_home }}"
mkdir -p backup

docker-compose exec -T plausible_events_db clickhouse-client --query "BACKUP DATABASE plausible_events_db TO File('/var/lib/clickhouse/backup/clickhouse.zip')"
docker-compose exec -T plausible_db pg_dump -d plausible_db -U postgres -Fc > backup/plausible_db.sql

mv event-data/backup/clickhouse.zip backup/

{{ bbclient_all }} create -xvs '::{now}' backup
{{ bbclient_all }} prune -vs --keep-within 7d --keep-daily=30 --keep-weekly=150
{{ bbclient_all }} compact --verbose

rm -rf -- ./backup
`,
    },
  },
] satisfies TaskFile;
