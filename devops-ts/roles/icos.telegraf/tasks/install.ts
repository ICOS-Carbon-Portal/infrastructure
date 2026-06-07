import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { omit } from "../../../lib/builtins.ts";
import { register } from "../../../lib/register.ts";
import { iff, tmpl } from "../../../lib/template.ts";

const _key = register("_key");

export default [
  {
    name: "Add influxdata key",
    "ansible.builtin.get_url": {
      url: "https://repos.influxdata.com/influxdata-archive_compat.key",
      dest: "/etc/apt/trusted.gpg.d/influxdata.asc",
      mode: "0644",
      force: true,
    },
    register: _key,
  },
  {
    name: "Add influxdata apt repository",
    apt_repository: {
      filename: "influxdata",
      repo:
        tmpl`deb [signed-by=${_key.dest.ref}] https://repos.influxdata.com/debian stable main`,
    },
  },
  {
    name: "Install telegraf",
    apt: {
      name: "telegraf",
      state: iff(V.telegraf_upgrade, "latest", "present"),
      // Setting this will also set update_cache. It's time consuming on slow
      // devices so set it to an hour.
      cache_valid_time: iff(V.telegraf_upgrade, 3600, omit),
    },
    notify: "restart telegraf",
  },
] satisfies TaskFile;
