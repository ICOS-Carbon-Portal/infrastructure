import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  // restart nebula etc
  {
    name: "Flush handlers",
    meta: "flush_handlers",
  },
  {
    when: [raw("nebula_resolve_servers"), raw("nebula_resolve_test")],
    block: [
      {
        name: "Install dnsutils",
        apt: {
          update_cache: true,
          cache_valid_time: 86400,
          name: "dnsutils",
        },
      },
      {
        name: "Check that nebula dns resolution works",
        shell: "dig {{ nebula_resolve_test }}",
        changed_when: false,
      },
    ],
  },
  {
    name: "Check that nebula is working",
    command: "ping -w 10 -c 1 {{ nebula_ping_host }}",
    changed_when: false,
  },
  {
    name: "Check that ordinary dns resolution is still working",
    command: "ping -w 10 -c 1 google.com",
    changed_when: false,
  },
] satisfies TaskFile;
