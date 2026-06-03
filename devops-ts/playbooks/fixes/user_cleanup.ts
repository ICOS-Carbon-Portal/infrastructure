// Fetch keys
//   icos play user_cleanup fetch
//
// Show unique ssh keys:
//  find /tmp/ssh-pub-keys -iname authorized_keys -print0 | sort -u --files0-from=-
//
// Show unique key comments
//  find /tmp/ssh-pub-keys -iname authorized_keys | xargs awk '{print $NF}'  | sort -u
//
// Pick keys to remove and list them as the `remove_keys` variable.
//
// Remove keys
//  icos play user_cleanup remove
import { pattern, type Playbook, V } from "../../lib/ansible.ts";

export default [
  {
    hosts: pattern("physical_servers", "fsicos2_vms", "fsicos3_vms"),
    vars: {
      lockuser: "username",
      remove_keys: ["ssh-rsa..."],
    },
    tasks: [
      {
        name: "Fetch root authorized_keys",
        tags: "fetch",
        fetch: {
          src: "/root/.ssh/authorized_keys",
          dest: "/tmp/ssh-pub-keys/",
        },
      },
      {
        name: "Remove specific root key",
        tags: "remove",
        authorized_key: {
          user: "root",
          key: V.item,
          state: "absent",
        },
        loop: V.remove_keys,
      },
      {
        tags: "lockuser",
        user: {
          name: V.lockuser,
          password_lock: true,
          shell: "/usr/sbin/nologin",
        },
      },
    ],
  },
] satisfies Playbook;
