import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Install nfs",
    apt: {
      name: ["nfs-kernel-server"],
    },
  },
  {
    name: "Allow nfs through firewall",
    when: raw("nfs4_interface"),
    iptables_raw: {
      name: "allow_nfs4",
      rules:
        '-A INPUT {{ "-i %s" % nfs4_interface if nfs4_interface else "" }} -p tcp --dport 2049 -j ACCEPT',
    },
  },
  {
    name: "Modify nfs-kernel parameters",
    lineinfile: {
      path: "/etc/default/nfs-kernel-server",
      regex: "^{{ item }}=",
      line:
        '{{ item }}="--no-nfs-version 2 --no-nfs-version 3 --nfs-version 4 --no-udp"\n',
      state: "present",
    },
    loop: ["RPCNFSDOPTS", "RPCMOUNTDOPTS"],
    notify: "restart nfs-kernel-server",
  },
  {
    import_tasks: "just.yml",
    tags: "nfs4_just",
  },
] satisfies TaskFile;
