import { zfsdocker_size, zfsdocker_zvol } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { zfsdocker_name } from "../../../lib/sharedvars.ts";
import { tmpl } from "../../../lib/template.ts";

export default [
  {
    name: tmpl`Create docker storage volume for ${zfsdocker_name}`,
    zfs: {
      name: tmpl`pool/docker/${zfsdocker_name}`,
      state: "present",
      extra_zfs_properties: {
        volsize: zfsdocker_size,
      },
    },
  },
  {
    name: tmpl`Create a btrfs filesystem on ${zfsdocker_name}`,
    tags: ["zfs", "zfsdocker"],
    filesystem: {
      dev: zfsdocker_zvol,
      fstype: "btrfs",
      // Label the filesystem, this makes the output from 'btrfs filesystem
      // show' easier to understand.
      opts: tmpl`-L docker_${zfsdocker_name}`,
    },
  },
  {
    name: "Change owner of btrfs filesystem",
    command:
      tmpl`unshare -m bash -c 'mount ${zfsdocker_zvol} /tmp; stat -c '%u:%g' /tmp; chown 1000000:1000000 /tmp'`,
    register: "r",
    changed_when: "r.stdout != '1000000:1000000'",
    failed_when: "r.rc != 0",
  },
] satisfies TaskFile;
