import { V } from "../_ctx.ts";
import { type TaskFile } from "../../../lib/ansible/play.ts";
import { item } from "../../../lib/builtins.ts";
import {
  destjarfile,
  jarservice_home,
  jarservice_local,
  jarservice_name,
} from "../../../lib/paramvars.ts";
import { register } from "../../../lib/register.ts";
import { tmpl } from "../../../lib/template.ts";
import { not, truthy } from "../../../lib/vars.ts";

const _old = register("_old");
const jardir = register("jardir");

const _stat = register("_stat");

export default [
  {
    name: "Create directory for jar files",
    file: {
      path: tmpl`${jarservice_home}/jarfiles`,
      state: "directory",
    },
    register: jardir,
  },
  {
    name: "Get checksum of local jar file.",
    become: false,
    local_action:
      tmpl`stat path="${jarservice_local}" checksum_algorithm=sha256`,
    register: _stat,
  },
  {
    name: "To aid debugging, explicitly check that the local jar file exist.",
    fail: { msg: tmpl`${jarservice_local} doesn't exist!` },
    when: not(_stat.stat.exists),
  },
  {
    name: "Compute the destination filename, we'll be using it more than once.",
    set_fact: {
      destjarfile:
        tmpl`${jardir.path.ref}/${jarservice_local.basename()}-${_stat.stat.checksum.ref}`,
    },
  },
  {
    name: tmpl`Copy ${jarservice_name} jar file`,
    copy: {
      src: jarservice_local,
      dest: destjarfile,
    },
    register: "jarservice_copy",
  },
  {
    name: tmpl`Create the ${jarservice_name} jar symlink used by systemd`,
    file: {
      src: destjarfile,
      dest: V.jarservice_jar,
      state: "link",
    },
    notify: tmpl`restart ${jarservice_name}`,
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
    file: tmpl`path=${item} state=absent`,
    with_items: [_old.stdout_lines.ref],
  },
] satisfies TaskFile;
