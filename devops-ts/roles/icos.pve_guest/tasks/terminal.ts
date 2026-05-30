import { register, type TaskFile } from "../../../lib/ansible.ts";

const _conf = register("_conf");

// https://wiki.archlinux.org/title/Getty#Automatic_login_to_virtual_console

export default [
  {
    name: "Create  directory",
    file: {
      path: "/etc/systemd/system/serial-getty@ttyS0.service.d",
      state: "directory",
    },
    register: "_mkdir",
  },
  {
    name: "Create ttyS0 override",
    copy: {
      dest: "{{ _mkdir.path }}/autologin.conf",
      content: `[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -- \\\\u' --keep-baud 115200,57600,38400,9600 --autologin root - $TERM
`,
    },
    register: _conf,
  },
  {
    name: "systemd reload",
    systemd: {
      daemon_reload: true,
    },
    when: _conf.changed,
  },
  {
    name: "Add securetty config to pam",
    blockinfile: {
      marker: "# {mark} ansible / pve_guest",
      create: true,
      insertafter: "BOF",
      path: "/etc/pam.d/login",
      block:
        "auth sufficient pam_listfile.so item=tty sense=allow file=/etc/securetty onerr=fail apply=root\n",
    },
  },
  {
    name: "Create /etc/securetty",
    copy: {
      dest: "/etc/securetty",
      content: `ttyS0
`,
    },
  },
] satisfies TaskFile;
