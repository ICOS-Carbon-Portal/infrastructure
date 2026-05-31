import { not, raw, register, type TaskFile } from "../../../lib/ansible.ts";
import { expr, rawTmpl, tmpl, V } from "../_ctx.ts";

const _stat = register("_stat");

export default [
  {
    name: "Create directory for jar files",
    file: {
      path: tmpl`${expr("jarservice_home")}/jarfiles`,
      state: "directory",
    },
    register: "jardir",
  },
  {
    name: "Get checksum of local jar file.",
    become: false,
    local_action: tmpl`stat path="${
      expr("jarservice_local")
    }" checksum_algorithm=sha256`,
    register: _stat,
  },
  {
    name: "To aid debugging, explicitly check that the local jar file exist.",
    fail: { msg: tmpl`${expr("jarservice_local")} doesn't exist!` },
    when: not(_stat.stat.exists),
  },
  {
    name: "Compute the destination filename, we'll be using it more than once.",
    set_fact: {
      destjarfile: tmpl`${expr("jardir.path")}/${
        expr("jarservice_local | basename")
      }-${expr("_stat.stat.checksum")}`,
    },
  },
  {
    name: tmpl`Copy ${expr("jarservice_name")} jar file`,
    copy: {
      src: expr("jarservice_local"),
      dest: expr("destjarfile"),
    },
    register: "jarservice_copy",
  },
  {
    name: tmpl`Create the ${
      rawTmpl("{{ jarservice_name}}")
    } jar symlink used by systemd`,
    file: {
      src: expr("destjarfile"),
      dest: V.jarservice_jar,
      state: "link",
    },
    notify: tmpl`restart ${expr("jarservice_name")}`,
    when: raw("jarservice_restart"),
  },
  {
    name: "Keep the jarfiles directory from filling up",
    shell: tmpl`ls -1t ${
      expr("jardir.path")
    }/*.jar-* 2>/dev/null | sed '1,${V.jarservice_keep_n_old}d'`,
    register: "_old",
    changed_when: false,
  },
  {
    name: "Remove old jarfiles",
    file: tmpl`path=${V.item} state=absent`,
    with_items: [expr("_old.stdout_lines")],
  },
] satisfies TaskFile;
