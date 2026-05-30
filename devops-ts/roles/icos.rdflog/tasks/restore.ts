import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "List tables in the rdflog database",
    command: "./psql.sh -c '\\d' rdflog",
    args: { chdir: V.rdflog_home, creates: "/some/file" },
    register: "_r",
    changed_when: false,
  },
  {
    debug: {
      msg: "The 'rdflog' database is not empty, not restoring.\n",
    },
    // YAML block-list of conditions (and-joined by Ansible). The typed `when`
    // accepts a single Expr, so this array is a deliberate type-error escape;
    // it renders to the same YAML sequence the original used.
    when: [
      raw("_r.stderr != 'Did not find any relations.'"),
      raw("_r.stdout != ''"),
    ],
  },
  {
    name: "Restore database from file",
    "ansible.builtin.shell": "zcat {{ rdflog_restore_file }} | ./psql.sh\n",
    args: { chdir: V.rdflog_home },
    register: "_r",
    when: [
      raw("_r.stderr == 'Did not find any relations.'"),
      raw("_r.stdout == ''"),
    ],
  },
] satisfies TaskFile;
