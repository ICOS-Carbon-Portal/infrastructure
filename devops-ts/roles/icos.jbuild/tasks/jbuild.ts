import { raw, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl } from "../_ctx.ts";

export default [
  {
    name: "Remove virtual env",
    file: {
      path: "/opt/jbuild/venv",
      state: "absent",
    },
    when: raw("virtualenv_recreate | default(False) | bool"),
  },
  {
    name: "Create virtual env",
    pip: {
      virtualenv: "/opt/jbuild/venv",
      name: ["click", "GitPython", "docker"],
      state: "present",
    },
  },
  {
    name: "Copy jbuild.py",
    copy: {
      src: "jbuild.py",
      dest: "/opt/jbuild/jbuild.py",
      mode: "+x",
      force: tmpl("{{ jbuild_force | default(True) | bool }}"),
    },
  },
  {
    name: "Create /usr/local/sbin/jbuild symlink",
    file: {
      dest: "/usr/local/sbin/jbuild",
      src: "/opt/jbuild/jbuild.py",
      state: "link",
    },
  },
  {
    name: "Check that jbuild executes",
    shell: "/usr/local/sbin/jbuild",
    changed_when: false,
  },
] satisfies TaskFile;
