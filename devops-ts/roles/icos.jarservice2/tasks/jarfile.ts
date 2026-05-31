import { not, raw, register, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const _stat = register("_stat");

export default [
  {
    name: "Create directory for jar files",
    file: {
      path: tmpl("{{ jarservice_home }}/jarfiles"),
      state: "directory",
    },
    register: "jardir",
  },
  {
    name: "Get checksum of local jar file.",
    become: false,
    local_action: tmpl(
      'stat path="{{ jarservice_local }}" checksum_algorithm=sha256',
    ),
    register: _stat,
  },
  {
    name: "To aid debugging, explicitly check that the local jar file exist.",
    fail: { msg: tmpl("{{ jarservice_local }} doesn't exist!") },
    when: not(_stat.stat.exists),
  },
  {
    name: "Compute the destination filename, we'll be using it more than once.",
    set_fact: {
      destjarfile: tmpl(
        "{{ jardir.path }}/{{ jarservice_local | basename }}-{{ _stat.stat.checksum }}",
      ),
    },
  },
  {
    name: tmpl("Copy {{ jarservice_name }} jar file"),
    copy: {
      src: tmpl("{{ jarservice_local }}"),
      dest: tmpl("{{ destjarfile }}"),
    },
    register: "jarservice_copy",
  },
  {
    name: tmpl("Create the {{ jarservice_name}} jar symlink used by systemd"),
    file: {
      src: tmpl("{{ destjarfile }}"),
      dest: V.jarservice_jar,
      state: "link",
    },
    notify: tmpl("restart {{ jarservice_name }}"),
    when: raw("jarservice_restart"),
  },
  {
    name: "Keep the jarfiles directory from filling up",
    shell:
      tmpl`ls -1t {{ jardir.path }}/*.jar-* 2>/dev/null | sed '1,${V.jarservice_keep_n_old}d'`,
    register: "_old",
    changed_when: false,
  },
  {
    name: "Remove old jarfiles",
    file: tmpl`path=${V.item} state=absent`,
    with_items: [tmpl("{{ _old.stdout_lines }}")],
  },
] satisfies TaskFile;
