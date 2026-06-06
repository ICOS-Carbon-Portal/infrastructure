import { type TaskFile } from "../../../lib/ansible/play.ts";
import { inventory_hostname } from "../../../lib/builtins.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: "Create private key",
    shell: "umask 077; wg genkey | tee privatekey | wg pubkey > publickey",
    args: {
      chdir: "/etc/wireguard",
      creates: "privatekey",
    },
  },
  {
    name: "Retrieve public key",
    fetch: {
      src: "/etc/wireguard/publickey",
      dest: tmpl`files/wireguard/${inventory_hostname}`,
      flat: true,
    },
  },
] satisfies TaskFile;
