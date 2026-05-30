import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

export default [
  {
    name: "Create cpmeta user",
    user: {
      name: V.cpmeta_user,
      home: V.cpmeta_home,
      shell: "/bin/bash",
    },
  },
  {
    name: "Copy SSL certs and private key for Handle.net client",
    copy: {
      src: "ssl",
      dest: tmpl`${V.cpmeta_home}/`,
      owner: V.cpmeta_user,
      group: V.cpmeta_user,
    },
  },
  {
    name: "Create metaAppStorage directory (if not present), take ownership",
    file: {
      path: V.cpmeta_filestorage_target,
      state: "directory",
      owner: V.cpmeta_user,
      group: V.cpmeta_user,
      recurse: true,
    },
  },
  {
    name: "Create rdfStorage directory (if not present), take ownership",
    file: {
      path: V.cpmeta_rdfstorage_path,
      state: "directory",
      owner: V.cpmeta_user,
      group: V.cpmeta_user,
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
