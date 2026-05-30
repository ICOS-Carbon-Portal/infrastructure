import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create doi user",
    user: {
      name: "{{ doi_user }}",
      home: "{{ doi_home }}",
      shell: "/bin/bash",
    },
  },
] satisfies TaskFile;
