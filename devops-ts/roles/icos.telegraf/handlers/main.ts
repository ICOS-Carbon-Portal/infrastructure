import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "reload telegraf",
    service: { name: "telegraf", state: "reloaded" },
  },
  {
    name: "restart telegraf",
    service: { name: "telegraf", state: "restarted" },
  },
] satisfies TaskFile;
