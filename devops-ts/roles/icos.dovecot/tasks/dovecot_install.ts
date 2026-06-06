import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Install dovecot",
    apt: {
      name: ["dovecot-imapd", "dovecot-lmtpd"],
      state: "present",
    },
  },
  {
    name: "Enable dovecot",
    service: {
      name: "dovecot",
      state: "started",
      enabled: true,
    },
  },
] satisfies TaskFile;
