import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Change postgres user password",
    // We're relying on 'peer' (unix socket) authentication for this to work.
    become: true,
    become_user: "postgres",
    postgresql_user: {
      name: "postgres",
      password: "{{ postgresql_postgres_password }}",
      login_unix_socket: "/var/run/postgresql",
    },
    when: [raw("postgresql_postgres_password")],
  },
  {
    name: "Change with addresses postgresql listens to",
    copy: {
      dest: "{{ postgresql_confd }}/listen.conf",
      content: `listen_addresses = {{ postgresql_listen_addresses }}
`,
    },
    notify: "restart postgresql",
    when: raw("postgresql_listen_addresses"),
  },
  {
    name: "Install public keys for postgres user",
    tags: "keys",
    authorized_key: {
      user: "postgres",
      state: "present",
      key: "{{ postgresql_ssh_keys }}",
    },
    when: raw("postgresql_ssh_keys"),
  },
] satisfies TaskFile;
