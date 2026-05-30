import { raw, type TaskFile } from "../../../lib/ansible.ts";

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
    when: raw("timer_state != 'absent'"),
  },
  {
    name: "Remove timer and service",
    import_tasks: "remove.yml",
    when: raw("timer_state == 'absent'"),
  },
] satisfies TaskFile;
