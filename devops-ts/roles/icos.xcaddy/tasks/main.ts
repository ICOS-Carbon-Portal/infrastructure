import { type TaskFile } from "../../../lib/ansible/play.ts";
import { ansible_distribution_file_variety } from "../../../lib/builtins.ts";
import { eq, ne } from "../../../lib/vars.ts";

export default [
  { import_role: { name: "icos.golang" } },
  {
    import_tasks: "xcaddy-debian.yml",
    when: eq(ansible_distribution_file_variety, "Debian"),
  },
  {
    import_tasks: "xcaddy-other.yml",
    when: ne(ansible_distribution_file_variety, "Debian"),
  },
] satisfies TaskFile;
