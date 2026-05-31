import { type TaskFile } from "../../../lib/ansible.ts";
import { tmpl, V } from "../_ctx.ts";

// PYTHON UTILS
export default [
  {
    name: "Synchronize stilt-utils source",
    "ansible.posix.synchronize": {
      src: "stilt-utils",
      dest: tmpl`${V.stiltweb_home}/`,
      // preserver owner and group, default is yes
      delete: true,
      owner: false,
      group: false,
      rsync_opts: [
        // read the .rsync-filter file
        "-F",
        "--delete-excluded",
      ],
    },
    register: "_rsync",
  },
  {
    name: "Install stilt-utils",
    become: true,
    become_user: V.stiltweb_username,
    "community.general.pipx": {
      executable: "pipx",
      python: "python3.12",
      editable: true,
      force: tmpl("{{ _rsync.changed }}"),
      name: tmpl`${V.stiltweb_home}/stilt-utils`,
    },
    register: "_pipx",
    // pipx seems to always report changed when installing editable from file
    changed_when: [
      "_pipx.changed",
      "_pipx.stdout",
      "_pipx.stdout.find('already seems to be installed') == -1",
    ],
    environment: {
      PIPX_BIN_DIR: V.stiltweb_bindir,
    },
  },
  // OTHER UTILS
  {
    name: "Install scripts",
    template: {
      src: V.item,
      dest: tmpl`${V.stiltweb_bindir}/`,
      owner: V.stiltweb_username,
      group: V.stiltweb_username,
      mode: 0o755,
    },
    with_items: [
      "tail-latest.sh",
      "sync-station-names.sh",
      "sync-fsicos1-to-fsicos2.sh",
    ],
  },
] satisfies TaskFile;
