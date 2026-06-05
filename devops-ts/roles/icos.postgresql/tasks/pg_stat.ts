import { and, register, type TaskFile } from "../../../lib/ansible.ts";

const _set = register("_set");

export default [
  {
    become: true,
    become_user: "postgres",
    block: [
      {
        name: "Add pg_stat_statements to postgresql shared_preload_libraries",
        "community.postgresql.postgresql_set": {
          name: "shared_preload_libraries",
          value: "pg_stat_statements",
        },
        register: _set,
      },
    ],
  },
  {
    name: "Restart postgresql",
    systemd: {
      name: "postgresql",
      state: "restarted",
    },
    // postgresql_set always reports 'restart_required' for the
    // 'shared_preload_libraries' key, even though it wasn't changed.
    when: and(_set.changed, _set.restart_required),
  },
  // pg_stat_statements still needs to be enabled in each database
  // - name: Add the pg_stat_statements extension
  //   community.postgresql.postgresql_ext:
  //     name: pg_stat_statements
  //     db: cplog
  //     schema: public
] satisfies TaskFile;
