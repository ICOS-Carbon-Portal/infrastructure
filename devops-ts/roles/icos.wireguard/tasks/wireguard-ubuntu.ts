import { type TaskFile } from "../../../lib/ansible/play.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Install wireguard",
    apt: {
      name: "wireguard",
      state: "present",
    },
  },
  {
    name: "Create wireguard-reresolve-dns.sh symlink",
    file: {
      dest: V.wireguard_reresolve_script,
      src:
        "/usr/share/doc/wireguard-tools/examples/reresolve-dns/reresolve-dns.sh",
      state: "link",
    },
  },
  {
    name: "Making a note that wireguard is installed",
    set_fact: {
      _wg_is_installed: 1,
      cacheable: true,
    },
  },
] satisfies TaskFile;
