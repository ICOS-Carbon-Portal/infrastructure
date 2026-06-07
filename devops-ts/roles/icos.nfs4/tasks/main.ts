import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import { iff, pct, tmpl } from "../../../lib/template.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  {
    name: "Install nfs",
    apt: {
      name: ["nfs-kernel-server"],
    },
  },
  {
    name: "Allow nfs through firewall",
    when: truthy(V.nfs4_interface),
    iptables_raw: {
      name: "allow_nfs4",
      rules: tmpl`-A INPUT ${
        iff(V.nfs4_interface, pct("-i %s", V.nfs4_interface), "")
      } -p tcp --dport 2049 -j ACCEPT`,
    },
  },
  {
    name: "Modify nfs-kernel parameters",
    lineinfile: {
      path: "/etc/default/nfs-kernel-server",
      regex: tmpl`^${item}=`,
      line:
        tmpl`${item}="--no-nfs-version 2 --no-nfs-version 3 --nfs-version 4 --no-udp"\n`,
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
