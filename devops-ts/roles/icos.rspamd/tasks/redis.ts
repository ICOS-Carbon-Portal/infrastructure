import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Install redis",
    apt: {
      name: "redis",
      state: "present",
    },
  },
  {
    name: "Configure rspamd to use redis",
    copy: {
      dest: "/etc/rspamd/local.d/redis.conf",
      content: `servers = "127.0.0.1";
`,
    },
    notify: "restart rspamd",
  },
] satisfies TaskFile;
