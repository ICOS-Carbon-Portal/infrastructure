import { register, type TaskFile } from "../../../lib/ansible.ts";
import { expr, rawTmpl, tmpl } from "../_ctx.ts";

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
      state: expr("'latest' if telegraf_upgrade else 'present'"),
      // Setting this will also set update_cache. It's time consuming on slow
      // devices so set it to an hour.
      cache_valid_time: rawTmpl("{{ 3600 if telegraf_upgrade else omit}}"),
    },
    notify: "restart telegraf",
  },
] satisfies TaskFile;
