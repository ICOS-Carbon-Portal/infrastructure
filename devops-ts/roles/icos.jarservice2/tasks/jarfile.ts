import { not, register, type TaskFile, truthy } from "../../../lib/ansible.ts";
import { rawTmpl, tmpl, V } from "../_ctx.ts";

const _old = register("_old");
const jardir = register("jardir");

const _stat = register("_stat");

export default [
  {
    name: "Create directory for jar files",
    file: {
      path: tmpl`${V.jarservice_home}/jarfiles`,
      state: "directory",
    },
    register: jardir,
  },
  {
    name: "Get checksum of local jar file.",
    become: false,
    local_action:
      tmpl`stat path="${V.jarservice_local}" checksum_algorithm=sha256`,
    register: _stat,
  },
  {
    name: "To aid debugging, explicitly check that the local jar file exist.",
    fail: { msg: tmpl`${V.jarservice_local} doesn't exist!` },
    when: not(_stat.stat.exists),
  },
  {
    name: "Compute the destination filename, we'll be using it more than once.",
    set_fact: {
      destjarfile:
        tmpl`${jardir.path.ref}/${V.jarservice_local.basename()}-${_stat.stat.checksum.ref}`,
    },
  },
  {
    name: tmpl`Copy ${V.jarservice_name} jar file`,
    copy: {
      src: V.jarservice_local,
      dest: V.destjarfile,
    },
    register: "jarservice_copy",
  },
  {
    name: tmpl`Create the ${
      rawTmpl("{{ jarservice_name}}")
    } jar symlink used by systemd`,
    file: {
      src: V.destjarfile,
      dest: V.jarservice_jar,
      state: "link",
    },
    notify: tmpl`restart ${V.jarservice_name}`,
    when: truthy(V.jarservice_restart),
  },
  {
    name: "Keep the jarfiles directory from filling up",
    shell:
      tmpl`ls -1t ${jardir.path.ref}/*.jar-* 2>/dev/null | sed '1,${V.jarservice_keep_n_old}d'`,
    register: _old,
    changed_when: false,
  },
  {
    name: "Remove old jarfiles",
    file: tmpl`path=${V.item} state=absent`,
    with_items: [_old.stdout_lines.ref],
  },
] satisfies TaskFile;
