import { type TaskFile } from "../../../lib/ansible/play.ts";
import { jbuild_force, virtualenv_recreate } from "../../../lib/paramvars.ts";
import { truthy } from "../../../lib/vars.ts";

export default [
  {
    name: "Remove virtual env",
    file: {
      path: "/opt/jbuild/venv",
      state: "absent",
    },
    when: truthy(virtualenv_recreate).default(false).bool(),
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
      force: jbuild_force.default(true).bool(),
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
