import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Create directory for jar files",
    file: {
      path: "{{ jarservice_home }}/jarfiles",
      state: "directory",
    },
    register: "jardir",
  },
  {
    name: "Get checksum of local jar file.",
    become: false,
    local_action:
      'stat path="{{ jarservice_local }}" checksum_algorithm=sha256',
    register: "_stat",
  },
  {
    name: "To aid debugging, explicitly check that the local jar file exist.",
    fail: { msg: "{{ jarservice_local }} doesn't exist!" },
    when: raw("not _stat.stat.exists"),
  },
  {
    name: "Compute the destination filename, we'll be using it more than once.",
    set_fact: {
      destjarfile:
        "{{ jardir.path }}/{{ jarservice_local | basename }}-{{ _stat.stat.checksum }}",
    },
  },
  {
    name: "Copy {{ jarservice_name }} jar file",
    copy: {
      src: "{{ jarservice_local }}",
      dest: "{{ destjarfile }}",
    },
    register: "jarservice_copy",
  },
  {
    name: "Create the {{ jarservice_name}} jar symlink used by systemd",
    file: {
      src: "{{ destjarfile }}",
      dest: "{{ jarservice_jar }}",
      state: "link",
    },
    notify: "restart {{ jarservice_name }}",
    when: raw("jarservice_restart"),
  },
  {
    name: "Keep the jarfiles directory from filling up",
    shell:
      "ls -1t {{ jardir.path }}/*.jar-* 2>/dev/null | sed '1,{{ jarservice_keep_n_old }}d'",
    register: "_old",
    changed_when: false,
  },
  {
    name: "Remove old jarfiles",
    file: "path={{ item }} state=absent",
    with_items: ["{{ _old.stdout_lines }}"],
  },
] satisfies TaskFile;
