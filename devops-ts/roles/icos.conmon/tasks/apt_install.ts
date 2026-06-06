import { conmon_apt_version_ok } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  {
    name: "Retrieve conmon_apt_version fact",
    check_mode: false,
    shellfact: {
      // "Version: 2.0.9-1" => "2.0.9"
      exec:
        "apt show conmon 2>/dev/null |  perl -ne '/Version: ([0-9.]+)/ && print $1'",
      fact: "conmon_apt_version",
    },
  },
  {
    name: "install conmon using apt",
    apt: {
      name: "conmon",
    },
    when: truthy(conmon_apt_version_ok),
  },
] satisfies TaskFile;
