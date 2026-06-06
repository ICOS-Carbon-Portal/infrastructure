import { golang_apt_version_ok } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  {
    name: "Retrieve golang_apt_version fact",
    check_mode: false,
    shellfact: {
      // "Version: 2:1.13~1ubuntu2' => "1.13"
      exec:
        "apt show golang-go 2>/dev/null | perl -ne '/Version: 2:([0-9.]+)/ && print $1'",
      fact: "golang_apt_version",
    },
  },
  {
    name: "install golang using apt",
    when: truthy(golang_apt_version_ok),
    apt: {
      name: "golang",
    },
  },
] satisfies TaskFile;
