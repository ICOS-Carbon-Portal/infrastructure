import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create docker storage volume for {{ zfsdocker_name }}",
    zfs: {
      name: "pool/docker/{{ zfsdocker_name }}",
      state: "present",
      extra_zfs_properties: {
        volsize: V.zfsdocker_size,
      },
    },
  },
  {
    name: "Create a btrfs filesystem on {{ zfsdocker_name }}",
    tags: ["zfs", "zfsdocker"],
    filesystem: {
      dev: V.zfsdocker_zvol,
      fstype: "btrfs",
      // Label the filesystem, this makes the output from 'btrfs filesystem
      // show' easier to understand.
      opts: "-L docker_{{ zfsdocker_name }}",
    },
  },
  {
    name: "Change owner of btrfs filesystem",
    command:
      tmpl`unshare -m bash -c 'mount ${V.zfsdocker_zvol} /tmp; stat -c '%u:%g' /tmp; chown 1000000:1000000 /tmp'`,
    register: "r",
    changed_when: "r.stdout != '1000000:1000000'",
    failed_when: "r.rc != 0",
  },
] satisfies TaskFile;
