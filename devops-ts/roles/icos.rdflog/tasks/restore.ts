import { eq, ne, register, type TaskFile } from "../../../lib/ansible.ts";

const _r = register("_r");
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "List tables in the rdflog database",
    command: "./psql.sh -c '\\d' rdflog",
    args: { chdir: V.rdflog_home, creates: "/some/file" },
    register: _r,
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
      ne(_r.stderr, "Did not find any relations."),
      ne(_r.stdout, ""),
    ],
  },
  {
    name: "Restore database from file",
    "ansible.builtin.shell": tmpl`zcat ${V.rdflog_restore_file} | ./psql.sh
`,
    args: { chdir: V.rdflog_home },
    register: _r,
    when: [
      eq(_r.stderr, "Did not find any relations."),
      eq(_r.stdout, ""),
    ],
  },
] satisfies TaskFile;
