import { raw, type TaskFile } from "../../../lib/ansible.ts";

export default [
  {
    name: "Synchronize icos-auto-dnat source",
    "ansible.posix.synchronize": {
      src: "icos-auto-dnat/",
      dest: "/opt/icos-auto-dnat",
      // preserver owner and group, default is yes
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
    name: "Install icos-auto-dnat",
    "community.general.pipx": {
      executable: "pipx-global",
      python: "python3",
      editable: true,
      force: true,
      name: "/opt/icos-auto-dnat/",
    },
    when: raw("_rsync.changed"),
    register: "_pipx",
    // pipx seems to always report changed when installing editable from file
    changed_when: [
      "_pipx.changed",
      "_pipx.stdout",
      "_pipx.stdout.find('already seems to be installed') == -1",
    ],
  },
  {
    name: "Copy auto-dnat service files",
    template: {
      src: "{{ item }}",
      dest: "/etc/systemd/system/",
      lstrip_blocks: true,
    },
    loop: [
      "icos-auto-dnat.path",
      "icos-auto-dnat.timer",
      "icos-auto-dnat.service",
    ],
    register: "_systemd",
  },
  {
    name: "Reload systemd",
    systemd: { "daemon-reload": true },
    when: raw("_systemd.changed"),
  },
  {
    name: "Start service",
    systemd: {
      name: "{{ item }}",
      enabled: true,
      state: "{{ 'restarted' if _systemd.changed else 'started' }}",
    },
    loop: ["icos-auto-dnat.path", "icos-auto-dnat.timer"],
  },
] satisfies TaskFile;
