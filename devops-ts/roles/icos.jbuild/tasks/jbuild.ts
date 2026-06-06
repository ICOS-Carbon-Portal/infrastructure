import { type TaskFile, truthy } from "../../../lib/ansible.ts";
import { V } from "../_ctx.ts";

export default [
  {
    name: "Remove virtual env",
    file: {
      path: "/opt/jbuild/venv",
      state: "absent",
    },
    when: truthy(V.virtualenv_recreate).default(false).bool(),
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
      force: V.jbuild_force.default(true).bool(),
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
