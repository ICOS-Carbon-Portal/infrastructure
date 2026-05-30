import { raw, type TaskFile, type When } from "../../../lib/ansible.ts";

export default [
  {
    name: "Fail if user is trying to remove main config file",
    fail: { msg: "Refusing to remove main config file." },
    when: [raw('telegraf_config_file == "telegraf.conf"')] as unknown as When,
  },
  {
    name: "Remove telegraf config file",
    file: {
      name: "{{ telegraf_config_root }}/{{ telegraf_config_file }}",
      state: "absent",
    },
    notify: "reload telegraf",
  },
] satisfies TaskFile;
