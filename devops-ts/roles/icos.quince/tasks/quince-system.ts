import { type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create quince user",
    user: {
      name: "{{ quince_user }}",
      home: "{{ quince_home | default(omit) }}",
      shell: "/bin/bash",
    },
  },
  {
    name: "Create quince filestore directory",
    file: {
      path: "{{ quince_filestore }}",
      state: "directory",
      owner: "{{ quince_user }}",
      group: "{{ quince_user }}",
    },
  },
  {
    name: "Install packages",
    apt: {
      name: "{{ item }}",
    },
    loop: ["mysql-server", "openjdk-{{ quince_jdk_version }}-jdk"],
  },
] satisfies TaskFile;
