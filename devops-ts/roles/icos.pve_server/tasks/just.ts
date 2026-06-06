import { type TaskFile } from "../../../lib/ansible/play.ts";
import { register } from "../../../lib/register.ts";

const _ops = register("_ops");

export default [
  {
    name: "Copy ops-proxmox-server",
    copy: {
      src: "ops-proxmox-server",
      dest: "/usr/local/bin/",
      mode: "+x",
    },
    register: _ops,
  },
  {
    name: "Check that the justfile is executable",
    shell: _ops.dest.ref,
    changed_when: false,
  },
  {
    name: "Add alias for ops-proxmox-server",
    lineinfile: {
      path: "/root/.bashrc",
      regex: "^alias [^=]+=ops-proxmox-server",
      line: "alias px=ops-proxmox-server",
      insertafter: "EOF",
      create: false,
    },
  },
  {
    name: "Check that alias and justfile works",
    "ansible.builtin.shell": "px",
    args: { executable: "/bin/bash" },
    changed_when: false,
    register: "_r",
    failed_when: ['"onboot" in _r.stdout'],
  },
] satisfies TaskFile;
