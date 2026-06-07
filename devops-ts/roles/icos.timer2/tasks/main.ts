import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { eq, ne } from "../../../lib/vars.ts";

export default [
  {
    name: "Check parameters",
    assert: {
      that: [
        "timer_state in ('started', 'stopped', 'absent')",
        "timer_name is defined",
        "timer_config is defined",
        "timer_service is defined",
      ],
    },
    check_mode: false,
  },
  {
    name: "Install timer and service",
    import_tasks: "setup.yml",
    when: ne(V.timer_state, "absent"),
  },
  {
    name: "Remove timer and service",
    import_tasks: "remove.yml",
    when: eq(V.timer_state, "absent"),
  },
] satisfies TaskFile;
