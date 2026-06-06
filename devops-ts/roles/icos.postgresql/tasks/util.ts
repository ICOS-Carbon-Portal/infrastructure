import { type TaskFile } from "../../../lib/ansible/play.ts";

export default [
  {
    name: "Install the icos_postgresql_util",
    import_role: {
      name: "icos.python_util",
    },
    vars: {
      python_util_src: "icos-postgresql-util",
    },
  },
] satisfies TaskFile;
