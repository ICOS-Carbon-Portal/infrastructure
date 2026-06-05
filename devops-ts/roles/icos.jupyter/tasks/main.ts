import { type TaskFile, truthy } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  { import_tasks: "setup.yml", tags: "jupyter_setup" },
  { import_tasks: "registry.yml", tags: "jupyter_registry" },
  {
    import_tasks: "jusers.yml",
    tags: "jupyter_jusers",
    when: truthy(V.jupyter_jusers_enable),
  },
  { import_tasks: "just.yml", tags: "jupyter_just" },
] satisfies TaskFile;
