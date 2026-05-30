import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "make sure we understand nginxsite_state",
    assert: { that: "nginxsite_state in ['present', 'absent']" },
  },
  {
    name: "add site",
    include_tasks: { file: "present.yml" },
    when: raw("nginxsite_state == 'present'"),
  },
  {
    name: "remove site",
    include_tasks: { file: "absent.yml" },
    when: raw("nginxsite_state == 'absent'"),
  },
] satisfies TaskFile;
