import { not, register, type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

const _stat = register("_stat");

export default [
  // We set up a directory where we keep not only the current jar file but also
  // older copies. This makes it easier to roll back to earlier versions of the
  // service - simply change the symbolic link and restart.
  {
    name: "Create directory for jar files",
    file: {
      path: tmpl("{{ _user.home }}/jarfiles"),
      state: "directory",
    },
    register: "jardir",
  },
  // Since we keep multiple versions of the jar files around, we need to
  // distinguish their file names by appending their checksum.
  {
    name: "Get checksum of local jar file.",
    // Stop ansible from running local_action as root (toplevel "become: true")
    become: false,
    local_action: tmpl('stat path="{{jarfile}}" checksum_algorithm=sha256'),
    register: _stat,
  },
  {
    name: "To aid debugging, explicitly check that the local jar file exist.",
    fail: { msg: tmpl("{{ jarfile }} doesn't exist!") },
    when: not(_stat.stat.exists),
  },
  {
    name: "Compute the destination filename, we'll be using it more than once.",
    set_fact: {
      destjarfile: tmpl(
        "{{jardir.path}}/{{jarfile|basename}}-{{_stat.stat.checksum}}",
      ),
    },
  },
  {
    name: tmpl("Copy {{ servicename }} jar file"),
    copy: {
      src: tmpl("{{ jarfile }}"),
      dest: tmpl("{{ destjarfile }}"),
    },
  },
  {
    name: tmpl("Create the {{ servicename}} jar symlink used by systemd"),
    file: {
      src: tmpl("{{ destjarfile }}"),
      dest: V.jarservice_jar,
      state: "link",
    },
    notify: tmpl("restart {{ servicename }}"),
  },
  {
    name: "Keep the jarfiles directory from filling up",
    shell: tmpl(
      "ls -1t {{ jardir.path }}/*.jar-* 2>/dev/null | sed '1,{{jarservice_keep_n_old}}d'",
    ),
    register: "oldjarfiles",
    changed_when: false,
  },
  {
    name: "Remove old jarfiles",
    file: tmpl`path=${V.item} state=absent`,
    with_items: [tmpl("{{ oldjarfiles.stdout_lines }}")],
  },
] satisfies TaskFile;
