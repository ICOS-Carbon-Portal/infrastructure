import { not, register, type TaskFile } from "../../../lib/ansible.ts";
import { rawTmpl, tmpl, V } from "../_ctx.ts";

// Registered by tasks/main.ts (this file is included after it).
const _user = register("_user");

const jardir = register("jardir");
const oldjarfiles = register("oldjarfiles");

const _stat = register("_stat");

export default [
  // We set up a directory where we keep not only the current jar file but also
  // older copies. This makes it easier to roll back to earlier versions of the
  // service - simply change the symbolic link and restart.
  {
    name: "Create directory for jar files",
    file: {
      path: tmpl`${_user.home.ref}/jarfiles`,
      state: "directory",
    },
    register: jardir,
  },
  // Since we keep multiple versions of the jar files around, we need to
  // distinguish their file names by appending their checksum.
  {
    name: "Get checksum of local jar file.",
    // Stop ansible from running local_action as root (toplevel "become: true")
    become: false,
    local_action: tmpl`stat path="${
      rawTmpl("{{jarfile}}")
    }" checksum_algorithm=sha256`,
    register: _stat,
  },
  {
    name: "To aid debugging, explicitly check that the local jar file exist.",
    fail: { msg: tmpl`${V.jarfile} doesn't exist!` },
    when: not(_stat.stat.exists),
  },
  {
    name: "Compute the destination filename, we'll be using it more than once.",
    set_fact: {
      destjarfile: tmpl`${rawTmpl("{{jardir.path}}")}/${
        rawTmpl("{{jarfile|basename}}")
      }-${rawTmpl("{{_stat.stat.checksum}}")}`,
    },
  },
  {
    name: tmpl`Copy ${V.servicename} jar file`,
    copy: {
      src: V.jarfile,
      dest: V.destjarfile,
    },
  },
  {
    name: tmpl`Create the ${
      rawTmpl("{{ servicename}}")
    } jar symlink used by systemd`,
    file: {
      src: V.destjarfile,
      dest: V.jarservice_jar,
      state: "link",
    },
    notify: tmpl`restart ${V.servicename}`,
  },
  {
    name: "Keep the jarfiles directory from filling up",
    shell: tmpl`ls -1t ${jardir.path.ref}/*.jar-* 2>/dev/null | sed '1,${
      rawTmpl("{{jarservice_keep_n_old}}")
    }d'`,
    register: oldjarfiles,
    changed_when: false,
  },
  {
    name: "Remove old jarfiles",
    file: tmpl`path=${V.item} state=absent`,
    with_items: [oldjarfiles.stdout_lines.ref],
  },
] satisfies TaskFile;
