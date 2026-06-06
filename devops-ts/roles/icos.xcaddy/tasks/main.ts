import { type TaskFile } from "../../../lib/ansible/play.ts";
import { eq, ne } from "../../../lib/vars.ts";
import { V } from "../_ctx.ts";

export default [
  { import_role: "name=icos.golang" },
  {
    import_tasks: "xcaddy-debian.yml",
    when: eq(V.ansible_distribution_file_variety, "Debian"),
  },
  {
    import_tasks: "xcaddy-other.yml",
    when: ne(V.ansible_distribution_file_variety, "Debian"),
  },
] satisfies TaskFile;
