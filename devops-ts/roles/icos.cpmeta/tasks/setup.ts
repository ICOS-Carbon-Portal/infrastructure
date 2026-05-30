import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create cpmeta user",
    user: {
      name: "{{ cpmeta_user }}",
      home: "{{ cpmeta_home }}",
      shell: "/bin/bash",
    },
  },
  {
    name: "Copy SSL certs and private key for Handle.net client",
    copy: {
      src: "ssl",
      dest: "{{ cpmeta_home }}/",
      owner: "{{ cpmeta_user }}",
      group: "{{ cpmeta_user }}",
    },
  },
  {
    name: "Create metaAppStorage directory (if not present), take ownership",
    file: {
      path: "{{ cpmeta_filestorage_target }}",
      state: "directory",
      owner: "{{ cpmeta_user }}",
      group: "{{ cpmeta_user }}",
      recurse: true,
    },
  },
  {
    name: "Create rdfStorage directory (if not present), take ownership",
    file: {
      path: "{{ cpmeta_rdfstorage_path }}",
      state: "directory",
      owner: "{{ cpmeta_user }}",
      group: "{{ cpmeta_user }}",
      recurse: true,
    },
  },
  {
    name: "Add systemd service",
    template: {
      src: "cpmeta.service",
      dest: "/etc/systemd/system/cpmeta.service",
    },
    register: "_service",
  },
  {
    name: "Restart systemd service daemon",
    systemd: {
      name: "cpmeta.service",
      enabled: true,
      "daemon-reload": true,
    },
    when: raw("_service.changed"),
  },
] satisfies TaskFile;
