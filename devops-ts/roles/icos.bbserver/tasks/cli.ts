import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create {{ bbserver_home }}/bin directory",
    file: {
      path: "{{ bbserver_home }}/bin",
      state: "directory",
      owner: "{{ bbserver_user }}",
      group: "{{ bbserver_user }}",
    },
  },
  {
    name: "Copy bbserver.py",
    template: {
      src: "bbserver.py",
      mode: "+x",
      dest: "{{ bbserver_home }}/bin/bbserver",
    },
  },
  {
    name: "Prime borg cache by running 'bbserver list' each night",
    cron: {
      user: "bbserver",
      job: "{{ bbserver_home }}/bin/bbserver list > /dev/null 2>&1",
      hour: "{{ 4 | random(seed='bbserver') }}",
      minute: "{{ 60 | random(seed='bbserver') }}",
      name: "bbserver_prime_borg_cache",
    },
  },
] satisfies TaskFile;
