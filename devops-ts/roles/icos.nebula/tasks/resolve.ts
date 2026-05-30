import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    when: raw('nebula_resolve_type == "probe"'),
    include_tasks: "resolve-probe.yml",
  },
  {
    when: raw('nebula_resolve_type == "dnsmasq"'),
    include_tasks: "resolve-dnsmasq.yml",
  },
  {
    when: raw('nebula_resolve_type == "NetworkManager"'),
    include_tasks: "resolve-networkmanager.yml",
  },
  {
    when: raw('nebula_resolve_type == "systemd-networkd"'),
    include_tasks: "resolve-networkd.yml",
  },
  {
    when: raw('nebula_resolve_type == "unknown"'),
    debug: {
      msg: `Don't know which network provisioner to configure.
`,
    },
  },
] satisfies TaskFile;
